# Troubleshooting

This describes frequent issues with the application setup and how to address them.

## Eventmachine error

When running `bundle install`, you may get the following error:
```
An error occurred while installing eventmachine (1.2.7), and Bundler cannot continue.
```

Try running the following command:
```
gem install eventmachine -- --with-openssl-dir=/usr/local/opt/openssl@1.1
```
If it's successful, run `bundle install` again.


If this doesn't work, you need to verify that openssl v1.1 is installed.

Try installing with:
```
brew install openssl@1.1
```

If it is already installed, you may need to add it to your shell path. From a terminal, run:
```
open ~/.zshrc
```

Add the following line and save the file:
```
export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl@1.1/lib/pkgconfig"
```

Rerun the command to install eventmachine, as above.
