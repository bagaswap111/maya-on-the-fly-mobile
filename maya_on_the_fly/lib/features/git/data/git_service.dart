import 'dart:io';
import 'package:git2dart/git2dart.dart' as git;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import '../../settings/data/database/app_database.dart';

const _uuid = Uuid();

class GitService {
  git.Repository? _repo;

  bool get isOpen => _repo != null;

  Future<git.Repository> openOrInit(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) await dir.create(recursive: true);

    try {
      _repo = git.Repository.open(path);
    } catch (_) {
      _repo = git.Repository.init(path: path);
    }

    _repo!.config['user.name'] = 'Maya on the Fly';
    _repo!.config['user.email'] = 'user@mayaonfly.app';

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await AppDatabase.instance.db.insert('repositories', {
      'id': _uuid.v4(),
      'name': p.basename(path),
      'local_path': path,
      'default_branch': _repo!.head.shorthand,
      'last_synced_at': timestamp,
      'unpushed_count': 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    return _repo!;
  }

  void close() {
    _repo?.free();
    _repo = null;
  }

  Map<String, Set<git.GitStatus>> get status {
    if (_repo == null) return {};
    return _repo!.status;
  }

  git.Repository get repo {
    if (_repo == null) throw StateError('No repository open');
    return _repo!;
  }

  void stageFile(String filePath) {
    final index = repo.index;
    index.add(filePath);
    index.write();
  }

  void stageAll() {
    final index = repo.index;
    index.addAll(repo.status.keys.toList());
    index.write();
  }

  void unstageFile(String filePath) {
    repo.resetDefault(oid: repo.head.target, pathspec: [filePath]);
  }

  String commit(String message) {
    repo.index.write();
    final oid = repo.createCommitOnHead(
      [],
      repo.defaultSignature,
      repo.defaultSignature,
      message,
    );
    return oid.sha;
  }

  List<git.Commit> log({int maxCount = 50}) {
    try {
      return repo.log(oid: repo.head.target);
    } catch (_) {
      return [];
    }
  }

  String? getDiff() {
    try {
      final diff = git.Diff.indexToWorkdir(repo: repo, index: repo.index);
      return diff.patch;
    } catch (_) {
      return null;
    }
  }

  String? getStagedDiff() {
    try {
      final headTree = git.Commit.lookup(repo: repo, oid: repo.head.target).tree;
      final diff = git.Diff.treeToIndex(repo: repo, tree: headTree, index: repo.index);
      return diff.patch;
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> getBranches() {
    return repo.branches.map((b) => {
      'name': b.name,
      'is_head': repo.head.shorthand == b.name,
    }).toList();
  }

  void createBranch(String name) {
    final branch = git.Branch.create(
      repo: repo,
      name: name,
      target: git.Commit.lookup(repo: repo, oid: repo.head.target),
    );
    final fullName = 'refs/heads/${branch.name}';
    git.Checkout.reference(repo: repo, name: fullName);
    repo.setHead(fullName);
  }

  void checkoutBranch(String name) {
    git.Checkout.reference(repo: repo, name: 'refs/heads/$name');
    repo.setHead('refs/heads/$name');
  }

  void deleteBranch(String name) {
    git.Branch.delete(repo: repo, name: name);
  }

  void addRemote(String name, String url) {
    git.Remote.create(repo: repo, name: name, url: url);
  }

  List<Map<String, String>> getRemotes() {
    return repo.remotes.map((name) {
      final remote = git.Remote.lookup(repo: repo, name: name);
      return {'name': remote.name, 'url': remote.url};
    }).toList();
  }

  void removeRemote(String name) {
    git.Remote.delete(repo: repo, name: name);
  }

  int getUnpushedCount() {
    try {
      final headOid = repo.head.target;
      final branchRef = 'refs/remotes/origin/${repo.head.shorthand}';
      final remoteRef = git.Reference.lookup(repo: repo, name: branchRef);
      final remoteOid = remoteRef.target;
      return repo.log(oid: headOid).length - repo.log(oid: remoteOid).length;
    } catch (_) {
      return 0;
    }
  }
}
