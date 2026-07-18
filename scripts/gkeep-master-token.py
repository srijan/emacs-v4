#!/usr/bin/env python3
"""One-time helper to obtain a Google Play Services master token for Keep API.

Usage:
    pip install gpsoauth
    python scripts/gkeep-master-token.py

The script will prompt for your Google email and an app password
(generate one at https://myaccount.google.com/apppasswords).

Copy the printed master token into your auth-source file:
    machine google-keep login master-token password <token>
"""

import getpass
import sys

try:
    import gpsoauth
except ImportError:
    print("Error: gpsoauth not installed. Run: pip install gpsoauth")
    sys.exit(1)

email = input("Google email: ").strip()
password = getpass.getpass("App password (from https://myaccount.google.com/apppasswords): ")

ANDROID_ID = "0000000000000000"

print("\nExchanging credentials for master token...")
result = gpsoauth.perform_master_login(email, password, ANDROID_ID)

if "Token" not in result:
    print(f"Error: {result.get('Error', 'Unknown error')}")
    if "NeedsBrowser" in result.get("Url", ""):
        print("You may need to approve access at the URL above.")
    sys.exit(1)

master_token = result["Token"]
print(f"\nMaster token obtained. Add this to your auth-source file:\n")
print(f"machine google-keep login email password {email}")
print(f"machine google-keep login master-token password {master_token}")
