# JSON Sanitizer Java Callout with Apigee Proxy

The repository is a final state of the JSON Sanitizer Lab.

See following ALfA lab for step-by-step explanations on how to build it.

https://apigee.github.io/alfa/edge-dev-javacallout


### Test Request

```
curl --cacert $RUNTIME_SSL_CERT -H "Content-Type: application/json" https://$RUNTIME_HOST_ALIAS/json-sanitizer --resolve "$RUNTIME_HOST_ALIAS:443:$RUNTIME_IP" --http1.1 --data-binary @- <<EOD                                                           
{"xx":"<script>alert(1)</script>", "yy": 'yyy',"ar":[0,,2]}
EOD
```
Expected Output:
```
{"xx":"<script>alert(1)<\/script>", "yy": "yyy","ar":[0,null,2]}
```


## Disclaimer

This example is not an official Google product, nor is it part of an official Google product.

## License

This material is copyright 2018-2019, Google LLC.
and is licensed under the Apache 2.0 license. See the [LICENSE](LICENSE) file.

## Status

This is a community supported project. There is no warranty for this code.
If you have problems or questions, ask on [commmunity.apigee.com](https://community.apigee.com).
