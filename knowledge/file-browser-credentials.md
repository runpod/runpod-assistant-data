# FileBrowser Default Credentials

Many Runpod templates include FileBrowser for managing files through a web interface.

## Default Credentials

The default credentials vary by template:

- **Most templates**: Username `admin`, password `admin`
- **Some templates**: Auto-generated credentials stored in environment variables or a config file

## Finding Your Credentials

1. **Check environment variables**: Look for `FILEBROWSER_USER` and `FILEBROWSER_PASS` in your pod's environment
2. **Check the template README**: The template documentation often specifies default credentials
3. **Check `/workspace/.filebrowser/`**: Some templates store credentials here

## Resetting FileBrowser Credentials

If you're locked out, connect via SSH or web terminal and run:

```bash
# Reset to default admin/admin
filebrowser users update admin --password admin

# Or create a new user
filebrowser users add newuser newpassword --perm.admin
```

## Common Templates with FileBrowser

- **ComfyUI templates**: Often use `admin` / `admin` or auto-generated credentials
- **Better ComfyUI Slim**: Check the template's environment variables for credentials

## Disabling FileBrowser Authentication

To disable password protection (not recommended for public pods):

```bash
filebrowser config set --auth.method=noauth
```

Then restart FileBrowser or your pod.
