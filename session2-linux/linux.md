## Task 1: Soft Link vs Hard Link

### Soft Link

A soft link is like a shortcut to another file. It points to the location of the original file. If the original file is deleted, the soft link will stop working. A soft link can point to both files and directories.

**Command:**

```bash
ln -s original_file soft_link
```

**Deleting a soft link:**

```bash
rm softlink.txt
```

Deleting the soft link does not delete the original file.

### Hard Link

A hard link is another name for the same file data. The original file and the hard link point to the same data. If the original file is deleted, the hard link will still work. Hard links normally cannot be created for directories.

**Command:**

```bash
ln original_file hard_link
```

**Deleting a hard link:**

```bash
rm hardlink.txt
```

Deleting the hard link does not delete the file data if the original file still exists.

## Task 2: adduser vs useradd

### adduser

`adduser` is a more user friendly command. It guides us through the user creation process. It can automatically create the home directory and ask for details like the password and user information.

**Example:**

```bash
sudo adduser testuser
```

It will ask us to set a password and enter some basic information.

### useradd

`useradd` is a lower level Linux command. It gives us more control over how the user is created. We usually need to provide extra options if we want to create the home directory and set other user settings.

**Example:**

```bash
sudo useradd -m testuser
```

The `-m` option creates the home directory for the user.

### Which command is preferred on Ubuntu/Linux?

On Ubuntu, `adduser` is generally preferred for creating users manually. The main reason is that it is easier to use and handles many steps automatically.

`useradd` is useful when we need more control or when creating users through scripts and automation.

### Create a Test User

We can create a test user using `adduser`.

```bash
sudo adduser testuser
```

The command will ask for a password and some optional user information.

To check if the user was created:

```bash
id testuser
```

We can also check the user's home directory:

```bash
ls /home
```

We should see the `testuser` directory.

### Remove the Test User

After testing, we can remove the user using:

```bash
sudo deluser testuser
```

If we also want to remove the user's home directory:

```bash
sudo deluser --remove-home testuser
```

## Task 3: journalctl

`journalctl` is a Linux command used to view system logs.

Linux keeps logs about different activities happening in the system. These logs can help us find errors, check what happened in the system, and troubleshoot problems.

`journalctl` reads these logs from the system journal.

### View System Logs

To view all available system logs:

```bash
journalctl
```

This can show a large number of logs.

To view the latest logs:

```bash
journalctl -e
```

The `-e` option takes us to the end of the logs.

To view only the most recent logs:

```bash
journalctl -n
```

We can also specify how many logs we want to see.

For example:

```bash
journalctl -n 20
```

This shows the last 20 log entries.

### View Logs in Real Time

We can use `-f` to continuously watch new logs.

```bash
journalctl -f
```

This is useful when we are testing a service and want to see new logs as they are created.

Press `Ctrl + C` to stop watching the logs.

### View Logs for a Specific Service

We can use `-u` to view logs for a specific service.

```bash
journalctl -u service_name
```

For example, to check the SSH service:

```bash
journalctl -u ssh
```

To see only the latest 20 SSH logs:

```bash
journalctl -u ssh -n 20
```

To watch new SSH logs in real time:

```bash
journalctl -u ssh -f
```

### View Logs for the Current Boot

To see logs from the current system boot:

```bash
journalctl -b
```

This is useful when we want to check what happened after the system was started.

### View Logs by Time

We can also check logs from a specific time.

For example:

```bash
journalctl --since "1 hour ago"
```

This shows logs from the last one hour.

We can also use:

```bash
journalctl --since today
```

This shows logs from today.

### Practice

First check the system logs:

```bash
journalctl -n 20
```

Then check the SSH service logs:

```bash
journalctl -u ssh
```

Check the latest 20 SSH logs:

```bash
journalctl -u ssh -n 20
```

Watch SSH logs in real time:

```bash
journalctl -u ssh -f
```

Press `Ctrl + C` to stop.

### Why is journalctl useful?

`journalctl` is useful for troubleshooting Linux systems.

For example, if a service is not working, we can check its logs using:

```bash
journalctl -u service_name
```

The logs can show errors and other information that can help us understand what went wrong.
