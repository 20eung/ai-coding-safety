#!/usr/bin/env python3
import sys
import subprocess
import json
import re
from datetime import datetime

def get_latest_tag():
    try:
        output = subprocess.check_output(["gh", "release", "list", "--limit", "1", "--json", "tagName", "--jq", ".[0].tagName"], stderr=subprocess.DEVNULL)
        return output.decode().strip()
    except:
        return ""

def get_commits_since(tag):
    try:
        if tag:
            log_range = f"{tag}..HEAD"
        else:
            log_range = "HEAD"
        
        output = subprocess.check_output(["git", "log", log_range, "--oneline", "--no-merges", "--pretty=format:%s"], stderr=subprocess.DEVNULL)
        return output.decode().splitlines()
    except:
        return []

def analyze_commits(commits):
    bump = "patch"
    categorized = {
        "breaking": [],
        "feat": [],
        "fix": [],
        "docs": [],
        "chore": []
    }
    
    for msg in commits:
        low_msg = msg.lower()
        if "breaking change:" in low_msg or "!" in msg.split(":")[0]:
            categorized["breaking"].append(msg)
            bump = "major"
        elif low_msg.startswith("feat:"):
            categorized["feat"].append(msg)
            if bump == "patch": bump = "minor"
        elif low_msg.startswith("fix:"):
            categorized["fix"].append(msg)
        elif low_msg.startswith("docs:"):
            categorized["docs"].append(msg)
        else:
            # chore, build, ci, refactor, style, test, perf...
            if not low_msg.startswith("chore: version"): # skip version bump commits
                categorized["chore"].append(msg)
                
    return bump, categorized

def format_changelog(bump, categorized, next_version):
    date_str = datetime.now().strftime("%Y-%m-%d")
    lines = [f"## {next_version} ({date_str})\n"]
    
    mapping = {
        "breaking": "🚨 Breaking Changes",
        "feat": "✨ New Features",
        "fix": "🐛 Bug Fixes",
        "docs": "📝 Documentation",
        "chore": "🔧 Others"
    }
    
    found_any = False
    for key, title in mapping.items():
        if categorized[key]:
            lines.append(f"### {title}")
            for item in categorized[key]:
                lines.append(f"- {item}")
            lines.append("")
            found_any = True
            
    if not found_any:
        lines.append("- (No specific changes found in git log)\n")
        
    lines.append("---\n")
    return "\n".join(lines)

def bump_version(current, bump_type):
    if not current: return "v1.0.0"
    v = current.lstrip('v')
    try:
        parts = list(map(int, v.split('.')))
    except:
        return "v1.0.0"
        
    if bump_type == 'major':
        parts[0] += 1
        parts[1] = 0
        parts[2] = 0
    elif bump_type == 'minor':
        parts[1] += 1
        parts[2] = 0
    elif bump_type == 'patch':
        parts[2] += 1
        
    return 'v' + '.'.join(map(str, parts))

def main():
    # 1. Latest Info
    latest_tag = get_latest_tag()
    commits = get_commits_since(latest_tag)
    
    if not commits:
        # Fallback if no commits found
        bump_type = "patch"
        categorized = {"breaking":[], "feat":[], "fix":[], "docs":[], "chore":[]}
    else:
        bump_type, categorized = analyze_commits(commits)
    
    # 2. Argument override
    requested_version = None
    if len(sys.argv) > 1 and sys.argv[1].startswith('v'):
        requested_version = sys.argv[1]
        
    next_version = requested_version or bump_version(latest_tag, bump_type)
    changelog_entry = format_changelog(bump_type, categorized, next_version)
    
    # 3. Output for shell
    result = {
        "latest_tag": latest_tag,
        "next_version": next_version,
        "bump_type": bump_type,
        "changelog_entry": changelog_entry,
        "has_commits": len(commits) > 0
    }
    print(json.dumps(result))

if __name__ == "__main__":
    main()
