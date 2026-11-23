import 'dart:convert';
import 'dart:io';

import 'package:ai_gym_lab/app/updater.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('버전 비교', () {
    expect(parseVersion('1.2.0'), [1, 2, 0]);
    expect(parseVersion('v1.2.0+7'), [1, 2, 0]);
    expect(parseVersion('abc'), isNull);
    expect(isNewerVersion('1.2.0', '1.1.2'), isTrue);
    expect(isNewerVersion('1.1.10', '1.1.9'), isTrue); // 글자 순서가 아니라 숫자로 비교
    expect(isNewerVersion('1.1.2', '1.1.2'), isFalse);
    expect(isNewerVersion('1.1.1', '1.1.2'), isFalse);
    expect(isNewerVersion('2.0', '1.9.9'), isTrue);
  });

  // test/fixtures/github_releases.json: 실제 GitHub API 응답(필요한 필드만)
  final real = jsonDecode(File('test/fixtures/github_releases.json').readAsStringSync()) as List;

  test('실제 GitHub 릴리스: 1.1.1에서는 1.1.2를 찾는다', () {
    final u = pickUpdate(real, '1.1.1')!;
    expect(u.version, '1.1.2');
    expect(u.apkUrl, endsWith('/gym-v1.1.2/AI_GYM_LAB_v1.1.2.apk'));
    expect(u.size, greaterThan(20 * 1024 * 1024));
    expect(u.notes, contains('중량 이어 채우기'));
    expect(u.notes, isNot(contains('**')));
  });

  test('실제 GitHub 릴리스: 이미 최신이면 업데이트 없음', () {
    expect(pickUpdate(real, '1.1.2'), isNull);
    expect(pickUpdate(real, '9.0.0'), isNull);
  });

  test('신문 릴리스·임시 저장·설치 파일 없는 릴리스는 건너뛰고 가장 새 버전을 고른다', () {
    Map<String, dynamic> rel(String tag, {bool draft = false, bool pre = false, bool apk = true}) => {
      'tag_name': tag,
      'draft': draft,
      'prerelease': pre,
      'body': '## 바뀐 것\n- **$tag** 변경',
      'assets': [
        if (apk) {'name': 'AI_GYM_LAB_$tag.apk', 'size': 100, 'browser_download_url': 'https://x/$tag.apk'},
        {'name': 'notes.txt', 'size': 1, 'browser_download_url': 'https://x/n'},
      ],
    };
    final list = [
      rel('news-2026-11-23'),
      rel('gym-v1.4.0', draft: true),
      rel('gym-v1.3.0', pre: true),
      rel('gym-v1.2.5', apk: false),
      rel('gym-v1.2.1'),
      rel('gym-v1.2.10'),
      rel('gym-v1.0.0'),
    ];
    final u = pickUpdate(list, '1.1.2')!;
    expect(u.version, '1.2.10');
    expect(u.apkUrl, 'https://x/gym-v1.2.10.apk');
    expect(u.notes, '· gym-v1.2.10 변경');
  });
}
