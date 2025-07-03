#!/usr/bin/env python3
"""
===================================
Git Version Control Script
Automated commit, tag, and release management
===================================
"""

import subprocess
import sys
import os
import json
import argparse
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Optional

from utils import Colors

class GitVersionControl:
    """Git version control automation"""
    
    def __init__(self, version: Optional[str] = None):
        self.version = version or "1.3.0" # Default version
        self.branch = "main"
        self.project_root = Path.cwd()
        
    def run_command(self, command: List[str], capture_output: bool = True, shell: bool = False) -> subprocess.CompletedProcess:
        """Run a shell command and return the result"""
        try:
            result = subprocess.run(
                command,
                capture_output=capture_output,
                text=True,
                check=False,
                cwd=self.project_root,
                shell=shell
            )
            return result
        except Exception as e:
            print(f"{Colors.RED}❌ Command failed: {e}{Colors.NC}")
            return subprocess.CompletedProcess(command, 1, "", str(e))

    def print_status(self, message: str, color: str = Colors.YELLOW):
        """Print a colored status message"""
        print(f"{color}{message}{Colors.NC}")

    def check_git_status(self) -> bool:
        """Check if we're in a git repository and get status"""
        self.print_status("🔍 Checking Git status...", Colors.BLUE)
        result = self.run_command(["git", "status", "--porcelain"])
        if result.returncode != 0:
            self.print_status("❌ Not in a Git repository", Colors.RED)
            return False
        
        if not result.stdout.strip():
            self.print_status("✅ Working directory clean", Colors.GREEN)
            return False # No changes to commit

        self.print_status("📋 Changes detected:", Colors.YELLOW)
        print(result.stdout.strip())
        return True

    def create_structured_commits(self):
        """Create structured commits based on file categories"""
        self.print_status("\n📝 Creating structured commits...", Colors.BLUE)

        # Add all changes to the index, including deletions
        self.run_command(["git", "add", "-A"])

        commit_groups = [
            {
                "message": "refactor(scripts): Consolidate validation and versioning scripts",
                "files": [
                    "version_control.py", "pre_commit_check.py",
                    "requirements-validation.txt"
                ]
            },
            {
                "message": "docs: Consolidate and clean up documentation files",
                "files": [
                    "README.md", "CHANGELOG.md", "CONTRIBUTING.md", "docs/"
                ]
            }
        ]

        # Commit refactoring and documentation changes first
        for group in commit_groups:
            # Use git diff to see if there are changes for this specific group
            # We need to check against HEAD for both staged and unstaged changes that we just added
            cmd = ["git", "diff", "--cached", "--quiet", "--"] + group["files"]
            result = self.run_command(cmd)

            # A non-zero exit code from `git diff --quiet` means there are differences
            if result.returncode != 0:
                commit_cmd = ["git", "commit", "-m", group["message"], "--"] + group["files"]
                commit_result = self.run_command(commit_cmd)
                if commit_result.returncode == 0:
                    self.print_status(f"✅ Commit created: {group['message']}", Colors.GREEN)
                else:
                    self.print_status(f"❌ Failed to commit: {group['message']}", Colors.RED)
                    print(commit_result.stderr)
                    # If a commit fails, we stop to avoid issues
                    return

        # Commit any remaining changes with a general message
        # We need to check for unstaged changes that are left
        self.run_command(["git", "add", "-A"])
        if self.check_git_status():
             self.print_status("⚙️ Committing remaining changes...", Colors.BLUE)
             final_commit_cmd = ["git", "commit", "-m", "chore: Apply remaining updates"]
             final_commit_result = self.run_command(final_commit_cmd)
             if final_commit_result.returncode == 0:
                 self.print_status("✅ Final commit created.", Colors.GREEN)
             else:
                 self.print_status("❌ Failed to create final commit.", Colors.RED)
                 print(final_commit_result.stderr)

    def create_tag(self):
        """Create and push a git tag"""
        tag = f"v{self.version}"
        self.print_status(f"\n🏷️ Creating tag {tag}...", Colors.BLUE)
        
        # Create tag
        tag_cmd = ["git", "tag", "-a", tag, "-m", f"Release version {self.version}"]
        result = self.run_command(tag_cmd)
        if result.returncode != 0 and "already exists" not in result.stderr:
            self.print_status(f"❌ Failed to create tag {tag}", Colors.RED)
            print(result.stderr)
            return

        # Push tag
        push_cmd = ["git", "push", "origin", tag]
        result = self.run_command(push_cmd)
        if result.returncode == 0:
            self.print_status(f"✅ Tag {tag} pushed successfully.", Colors.GREEN)
        else:
            self.print_status(f"❌ Failed to push tag {tag}", Colors.RED)
            print(result.stderr)

class GitHubReleaseCreator:
    def __init__(self, version: str):
        self.version = version
        self.tag = f"v{self.version}"
        self.release_notes_file = Path("docs") / "release-notes.md"

    def check_gh_cli(self) -> bool:
        """Check if GitHub CLI is available"""
        print("\n🔍 Checking for GitHub CLI...")
        try:
            result = subprocess.run(["gh", "--version"], capture_output=True, text=True, check=True)
            print("✅ GitHub CLI available")
            return True
        except (subprocess.CalledProcessError, FileNotFoundError):
            print("❌ GitHub CLI not found or not working.")
            print("💡 Install from: https://cli.github.com/")
            return False

    def check_gh_auth(self) -> bool:
        """Check GitHub authentication status"""
        print("\n🔐 Checking GitHub authentication...")
        try:
            result = subprocess.run(["gh", "auth", "status"], capture_output=True, text=True, check=True)
            print("✅ Authenticated with GitHub")
            return True
        except subprocess.CalledProcessError:
            print("❌ Not authenticated with GitHub.")
            print("💡 Run: gh auth login")
            return False

    def create_release(self):
        """Create a new GitHub release"""
        if not self.check_gh_cli() or not self.check_gh_auth():
            sys.exit(1)

        print(f"\n🚀 Creating GitHub release for tag {self.tag}...")
        if not self.release_notes_file.exists():
            print(f"❌ Release notes not found at {self.release_notes_file}")
            sys.exit(1)

        cmd = [
            "gh", "release", "create", self.tag,
            "--title", f"Release v{self.version}",
            "--notes-file", str(self.release_notes_file),
            "--latest"
        ]

        try:
            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            print(f"\n✅ {Colors.GREEN}Release created successfully!{Colors.NC}")
            print(f"🔗 URL: {result.stdout.strip()}")
        except subprocess.CalledProcessError as e:
            print(f"\n❌ {Colors.RED}Failed to create GitHub release.{Colors.NC}")
            print(e.stderr)
            if "release with this tag already exists" in e.stderr:
                print(f"💡 A release for tag {self.tag} already exists.")
            sys.exit(1)

def main():
    """Main function to drive the script"""
    Colors.init()
    parser = argparse.ArgumentParser(description="Git Version Control and Release Tool")
    parser.add_argument("action", choices=["commit", "tag", "release"], help="The action to perform")
    parser.add_argument("--version", help="The version number to use (e.g., 1.3.0)")

    args = parser.parse_args()

    if not args.version and (args.action == 'tag' or args.action == 'release'):
        parser.error("--version is required for 'tag' and 'release' actions.")

    git_control = GitVersionControl(version=args.version)

    if args.action == "commit":
        if git_control.check_git_status():
            git_control.create_structured_commits()
        else:
            print("No changes to commit.")
    
    elif args.action == "tag":
        git_control.create_tag()

    elif args.action == "release":
        release_creator = GitHubReleaseCreator(version=args.version)
        release_creator.create_release()

if __name__ == "__main__":
    main()
