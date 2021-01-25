# plutus

## Using this skeleton

This skeleton uses Exgen to generate a brand new application with the following things done:

* Phoenix & Ecto installed and configured
* CircleCI configured
* Dockerfile
* Basic chart for kubernetes deploy

To do this, you first need Exgen:

```
curl -LO https://github.com/silverp1/exgen/blob/main/exgen-0.5.2.ez?raw=true
mix archive.install exgen-0.5.2.ez
```

Next run the generator using in your development directory (not in an existing project):

```
mix exgen.new <dir_name> -t https://github.com/silverp1/elixir-skeleton.git --app-name <app_name> --module <module_name>
```

Where:

* `dir_name` - The directory of the new project to be created
* `app_name` - This is used for the OTP app name and for file naming
* `module_name` - This is the module used for Phoenix, you'll have `$MODULE_NAME` and `$MODULE_NAME`_web


## Using the app afterwords

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.