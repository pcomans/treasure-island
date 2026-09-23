# Approved identity is an opaque input, never inferred by replacing unit digits.
APPROVED_BASE = 'fdfc100704200e6570b654a4e6a4fccc9a1a61be'
git_marker = (R / '.git').read_text().strip()
assert git_marker.startswith('gitdir: '), 'Expected the reviewed worktree marker'
gitdir = Path(git_marker[len('gitdir: '):])
if not gitdir.is_absolute():
 gitdir = R / gitdir
actual_head = (gitdir / 'HEAD').read_text().strip()
assert re.fullmatch(r'[a-f0-9]{40}', actual_head), 'Expected an exact detached HEAD'
runner_tree = ast.parse((W / 'run-stage.py').read_text())
head_expression = ast.dump(ast.parse("(gitdir / 'HEAD').read_text().strip()", mode='eval').body)
head_guards = [node.test for node in ast.walk(runner_tree)
 if isinstance(node, ast.Assert) and isinstance(node.test, ast.Compare)
 and len(node.test.ops) == len(node.test.comparators) == 1
 and isinstance(node.test.ops[0], ast.Eq)
 and ast.dump(node.test.left) == head_expression]
assert len(head_guards) == 1, 'Expected exactly one literal runner HEAD guard'
guard_value = head_guards[0].comparators[0]
assert isinstance(guard_value, ast.Constant) and type(guard_value.value) is str, 'HEAD guard must be literal'
assert actual_head == guard_value.value == APPROVED_BASE, 'Actual HEAD, runner guard and approved base differ'
# All identity assertions precede source-map, route, plan or FILE_READY writes.
