if ("serviceWorker" in navigator) {
  window.addEventListener("load", function () {
    navigator.serviceWorker.register("flutter_service_worker.js?v=1586093890");
  });
}
