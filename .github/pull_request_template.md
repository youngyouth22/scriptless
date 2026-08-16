## Description
<!-- Provide a clear and concise summary of what this PR introduces or fixes. -->

### What
- 

### Why
- 

### How
- 

---

## Type of Change
<!-- Please check all options that apply: -->
- [ ] `feat`: A new feature
- [ ] `fix`: A bug fix
- [ ] `refactor`: Code restructuring without functional changes
- [ ] `test`: Adding or updating unit / bloc tests
- [ ] `docs`: Documentation updates
- [ ] `chore`: Tooling, dependencies, or CI/CD updates

---

## Test Plan
<!-- Describe the tests you ran to verify your changes. Include unit tests, bloc tests, or manual test scenarios. -->
- [ ] `flutter test --coverage` passes with 100% Domain coverage and >= 80% overall
- [ ] `flutter analyze --fatal-infos --fatal-warnings` passes with 0 issues
- [ ] `dart format --set-exit-if-changed lib/ test/` passes

---

## Screenshots / Videos (If UI Change)
| Before | After |
| :---: | :---: |
| *N/A* | *N/A* |

---

## Quality Checklist
- [ ] My code adheres to Clean Architecture layer separation (Domain / Data / Presentation).
- [ ] All public APIs are documented with `///`.
- [ ] No hardcoded secrets, API keys, or tokens.
- [ ] PowerSync & Supabase models strictly match schema rules (no `id` in Dart schema, proper types).
- [ ] No logic inside build methods; all state is managed via BLoC/Cubit.
- [ ] No warnings or hints in analyzer.
