#!/usr/bin/env bats

setup () {
  # Files.
  : >> "$BATS_TEST_TMPDIR/file1"
  : >> "$BATS_TEST_TMPDIR/file2"

  # File symlinks.
  ln -s file1 "$BATS_TEST_TMPDIR/link1"
  ln -s file2 "$BATS_TEST_TMPDIR/link2"

  # Orphaned symlinks.
  ln -s file3 "$BATS_TEST_TMPDIR/link3"
  ln -s file4 "$BATS_TEST_TMPDIR/link4"
}

xunlink () {
  bin/xunlink "$@"
}

@test "unlinks multiple symlink files" {
  [[ -h "$BATS_TEST_TMPDIR/link1" ]]
  [[ -h "$BATS_TEST_TMPDIR/link2" ]]
  [[ -h "$BATS_TEST_TMPDIR/link3" ]]
  [[ -h "$BATS_TEST_TMPDIR/link4" ]]

  run xunlink \
    "$BATS_TEST_TMPDIR/link1" \
    "$BATS_TEST_TMPDIR/link2" \
    "$BATS_TEST_TMPDIR/link3" \
    "$BATS_TEST_TMPDIR/link4" \
    ;

  [[ "$status" == 0 ]]
  [[ ! -e "$BATS_TEST_TMPDIR/link1" ]]
  [[ ! -e "$BATS_TEST_TMPDIR/link2" ]]
  [[ ! -e "$BATS_TEST_TMPDIR/link3" ]]
  [[ ! -e "$BATS_TEST_TMPDIR/link4" ]]
}

@test "only unlinks orphaned symlink files if '--only-orphan' is supplied" {
  [[ -h "$BATS_TEST_TMPDIR/link1" ]]
  [[ -h "$BATS_TEST_TMPDIR/link2" ]]
  [[ -h "$BATS_TEST_TMPDIR/link3" ]]
  [[ -h "$BATS_TEST_TMPDIR/link4" ]]

  run xunlink \
    --only-orphan \
    "$BATS_TEST_TMPDIR/link1" \
    "$BATS_TEST_TMPDIR/link2" \
    "$BATS_TEST_TMPDIR/link3" \
    "$BATS_TEST_TMPDIR/link4" \
    ;

  [[ "$status" == 0 ]]
  [[ -h "$BATS_TEST_TMPDIR/link1" ]]
  [[ -h "$BATS_TEST_TMPDIR/link2" ]]
  [[ ! -e "$BATS_TEST_TMPDIR/link3" ]]
  [[ ! -e "$BATS_TEST_TMPDIR/link4" ]]
}

@test "doesn't unlink not symlink files" {
  [[ -e "$BATS_TEST_TMPDIR/file1" ]]
  [[ -e "$BATS_TEST_TMPDIR/file2" ]]

  run xunlink \
    "$BATS_TEST_TMPDIR/file1" \
    "$BATS_TEST_TMPDIR/file2" \
    ;

  [[ "$status" == 0 ]]
  [[ -e "$BATS_TEST_TMPDIR/file1" ]]
  [[ -e "$BATS_TEST_TMPDIR/file2" ]]
}

@test "doesn't unlink any symlink files if '--dry-run' is supplied" {
  [[ -h "$BATS_TEST_TMPDIR/link1" ]]
  [[ -h "$BATS_TEST_TMPDIR/link2" ]]
  [[ -h "$BATS_TEST_TMPDIR/link3" ]]
  [[ -h "$BATS_TEST_TMPDIR/link4" ]]

  run xunlink \
    --dry-run \
    "$BATS_TEST_TMPDIR/link1" \
    "$BATS_TEST_TMPDIR/link2" \
    "$BATS_TEST_TMPDIR/link3" \
    "$BATS_TEST_TMPDIR/link4" \
    ;

  [[ "$status" == 0 ]]
  [[ -h "$BATS_TEST_TMPDIR/link1" ]]
  [[ -h "$BATS_TEST_TMPDIR/link2" ]]
  [[ -h "$BATS_TEST_TMPDIR/link3" ]]
  [[ -h "$BATS_TEST_TMPDIR/link4" ]]
}

@test "always show a help message if '-h|--help' is supplied even if any flags or any arguments are supplied" {
  run xunlink -h
  [[ "$status" == 0 ]]
  [[ "${lines[0]}" == Descriptions: ]]

  run xunlink --help
  [[ "$status" == 0 ]]
  [[ "${lines[0]}" == Descriptions: ]]

  run xunlink \
    --help \
    --verbose \
    "$BATS_TEST_TMPDIR/link1" \
    "$BATS_TEST_TMPDIR/link2" \
    ;
  [[ "$status" == 0 ]]
  [[ "${lines[0]}" == Descriptions: ]]

  run xunlink \
    --verbose \
    "$BATS_TEST_TMPDIR/link1" \
    "$BATS_TEST_TMPDIR/link2" \
    --help \
    ;
  [[ "$status" == 0 ]]
  [[ "${lines[0]}" == Descriptions: ]]
}
