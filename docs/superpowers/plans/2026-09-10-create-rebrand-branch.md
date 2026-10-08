# Create Branch for GDG Rebrand

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the 5 GDG rebrand commits from `master` to a dedicated feature branch.

**Architecture:** Create `feature/gdg-brand-rebrand` from current master, then reset master to `origin/master`.

**Tech Stack:** Git

---

### Task 1: Create branch and reset master

- [ ] **Step 1: Create the new branch from current HEAD**

```bash
git branch feature/gdg-brand-rebrand
```

- [ ] **Step 2: Verify branch exists**

```bash
git branch -v | grep gdg-brand-rebrand
```

Expected: shows `a24a18c refactor: update treasure modal gradient to GDG yellow`

- [ ] **Step 3: Switch to master and reset to origin**

```bash
git checkout master
git reset --hard origin/master
```

- [ ] **Step 4: Verify master is clean**

```bash
git log --oneline -3
```

Expected: shows `bf4f637` as HEAD (the commit before rebranding)

- [ ] **Step 5: Switch back to feature branch**

```bash
git checkout feature/gdg-brand-rebrand
```

- [ ] **Step 6: Verify feature branch has all 5 commits**

```bash
git log --oneline -6
```

Expected: shows the 5 rebrand commits + `bf4f637` as base
