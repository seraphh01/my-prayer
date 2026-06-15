{{flutter_js}}
{{flutter_build_config}}

function hideFlutterLoading() {
  var loading = document.getElementById('flutter-loading');
  if (!loading || loading.dataset.hidden === 'true') {
    return;
  }
  loading.dataset.hidden = 'true';
  loading.classList.add('is-hidden');
  window.setTimeout(function () {
    loading.remove();
  }, 240);
}

window.hideFlutterLoading = hideFlutterLoading;

window.addEventListener('flutter-first-frame', hideFlutterLoading);
window.setTimeout(hideFlutterLoading, 12000);

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine({});
    await appRunner.runApp();
    hideFlutterLoading();
  },
});
