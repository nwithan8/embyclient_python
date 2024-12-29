## DEPRECATED

After discussions with the Emby development team, management over an official Emby Python API client package will be migrated over to their systems. This repository and the corresponding PyPi package are now considered deprecated.

# Emby Python Client

A Python client for Emby Media Server's API.

This repository is an automated release of
the [Emby Python SDK](https://github.com/MediaBrowser/Emby.SDK/tree/master/SampleCode/RestApi/Clients/Python) with
improvements and modifications to clean up junk due to the SDK being auto-generated from an OpenAPI spec.

Modifications include:

- Improved README documentation
- Improved `setup.py` needed for PyPi distribution process
- Rename `embyclient-python` to `embyclient` for easier usage (dash in package name is not allowed in Python, not sure
  why it was ever there in the first place)

On a cron schedule, GitHub Actions will check for a new release of the Emby SDK and automatically build and release a
new version of this package accordingly.

This project is unofficial and not affiliated with Emby, but since they seem to refuse to build quality SDKs and
actually release them through traditional package manager channels, I've taken it upon myself to do so.
