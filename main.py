#!/usr/bin/env python3
"""
Roblox Username Hash Generator
Generates SHA256 hash for Roblox usernames to be used in whitelist.json
"""
 
import hashlib
import json
import sys
 
 
def generate_hash(username):
    """Generate SHA256 hash of a username"""
    return hashlib.sha256(username.encode()).hexdigest()
 
 
def add_user_to_whitelist(user_id, username, attackable=False, level=1, tags=None):
    """Add a user to the whitelist.json file"""
    if tags is None:
        tags = [{"text": "Owner", "color": [255, 0, 0]}]
 
    user_hash = generate_hash(username)
 
    try:
        with open('whitelist.json', 'r') as f:
            whitelist = json.load(f)
    except FileNotFoundError:
        whitelist = {"WhitelistedUsers": {}}
 
    whitelist["WhitelistedUsers"][str(user_id)] = {
        "name": username,
        "hash": user_hash,
        "attackable": attackable,
        "level": level,
        "tags": tags
    }
 
    with open('whitelist.json', 'w') as f:
        json.dump(whitelist, f, indent=2)
 
    print(f"Added user {username} (ID: {user_id}) to whitelist")
    print(f"Hash: {user_hash}")
 
 
def main():
    if len(sys.argv) < 2:
        print("Usage: python generate_hash.py <username> [user_id] [attackable] [level]")
        print("Example: python generate_hash.py 0801Lucas 445070253 false 3")
        print("\nOr just generate a hash:")
        print("Usage: python generate_hash.py <username>")
        print("Example: python generate_hash.py 0801Lucas")
        return
 
    username = sys.argv[1]
 
    if len(sys.argv) >= 3:
        user_id = sys.argv[2]
        attackable = sys.argv[3].lower() == 'true' if len(sys.argv) >= 4 else False
        level = int(sys.argv[4]) if len(sys.argv) >= 5 else 1
 
        add_user_to_whitelist(user_id, username, attackable, level)
    else:
        # Just generate and display the hash
        user_hash = generate_hash(username)
        print(f"Username: {username}")
        print(f"SHA256 Hash: {user_hash}")
        print(f"\nAdd this to your whitelist.json:")
        print(f'  "{user_id}": {{')
        print(f'    "name": "{username}",')
        print(f'    "hash": "{user_hash}",')
        print(f'    "attackable": false,')
        print(f'    "level": 3,')
        print(f'    "tags": [')
        print(f'      {{')
        print(f'        "text": "Owner",')
        print(f'        "color": [255, 0, 0]')
        print(f'      }}')
        print(f'    ]')
        print(f'  }}')
 
 
if __name__ == "__main__":
    main()