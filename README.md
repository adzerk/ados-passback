# ados-passback.js

The Adzerk passback code is served as a 3rd party creative to trigger an Ados
passback. Ados will then load the next flight in the passback chain.

* Read more about [setting up the AdChain][adchain] in the Adzerk Knowledge Base.

## Usage

Here is an example passback code that would be served from a 3rd party adserver,
assuming the corresponding Adzerk flight ID is `12345`:

```html
<script src="https://static.adzerk.net/ados-passback.js"></script>
<script type="text/javascript">
  passbackToAdzerk(12345);
  // Where 12345 is the ID of the Adzerk flight that is triggering the passback
</script>
```

Note the `ados-passback.js` script above &mdash; the contents of this repository.

## Build

```
make
```

[adchain]: https://dev.adzerk.com/docs/setting-up-adchain
