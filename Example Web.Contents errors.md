# Web.Contents errors

## TLS failure, but the url is valid

```
DataSource.Error: The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel.
Details:
    https://wrong.host.badssl.com/
```

## Url does not exist

```
DataSource.Error: The remote name could not be resolved: 'www.somefakenamedoesnotexist.com'
Details:
    http://www.somefakenamedoesnotexist.com
```