// Nana's Library — 全站唯一的 JS（CLAUDE.md 第 2、5、6 節）
// 1. 今年讀了幾本  2. 分類篩選按鈕  3. 點書時翻開封面再進入書頁  4. 書單抽屜

(function () {
  var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var shelf = document.querySelector("[data-shelf]");

  // 1. 今年讀了幾本：依每本書的 data-finished（YYYY、YYYY-MM 或 YYYY-MM-DD）的年份計算
  var countEl = document.querySelector("[data-year-count]");
  if (countEl && shelf) {
    var year = String(new Date().getFullYear());
    var count = shelf.querySelectorAll('.shelf-item[data-finished^="' + year + '"]').length;
    countEl.textContent = count > 0
      ? year + " 年讀了 " + count + " 本"
      : "今年的第一本書還在路上";
  }

  // 2. 分類篩選：按鈕依書架上現有的分類自動產生，只篩選書架
  var filterBox = document.querySelector("[data-filters]");
  if (filterBox && shelf) {
    var items = Array.prototype.slice.call(shelf.querySelectorAll(".shelf-item"));
    var categories = [];
    items.forEach(function (item) {
      var c = item.getAttribute("data-category");
      if (c && categories.indexOf(c) === -1) categories.push(c);
    });

    var buttons = [];
    ["全部"].concat(categories).forEach(function (name) {
      var btn = document.createElement("button");
      btn.type = "button";
      btn.className = "filter-btn";
      btn.textContent = name;
      btn.setAttribute("aria-pressed", name === "全部" ? "true" : "false");
      btn.addEventListener("click", function () {
        buttons.forEach(function (b) { b.setAttribute("aria-pressed", b === btn ? "true" : "false"); });
        items.forEach(function (item) {
          item.hidden = !(name === "全部" || item.getAttribute("data-category") === name);
        });
      });
      buttons.push(btn);
      filterBox.appendChild(btn);
    });
  }

  // 3. 點書：封面翻開（約 0.6 秒）後進入書頁；減少動態效果時直接進入
  document.querySelectorAll("a.shelf-item").forEach(function (link) {
    link.addEventListener("click", function (event) {
      if (reduceMotion || event.metaKey || event.ctrlKey || event.shiftKey || event.button !== 0) return;
      event.preventDefault();
      link.classList.add("is-opening");
      setTimeout(function () { window.location.href = link.href; }, 650);
    });
  });

  // 4. 書單抽屜：點「Up next」從右側滑出；按 ✕、點旁邊空白或按 Esc 收回
  var drawer = document.getElementById("up-next");
  var openBtn = document.querySelector("[data-drawer-open]");
  if (drawer && openBtn) {
    var countSpan = document.querySelector("[data-up-next-count]");
    if (countSpan) countSpan.textContent = drawer.querySelectorAll(".up-next-item").length;

    var setOpen = function (open) {
      document.body.classList.toggle("drawer-open", open);
      drawer.setAttribute("aria-hidden", open ? "false" : "true");
      openBtn.setAttribute("aria-expanded", open ? "true" : "false");
      if (open) drawer.querySelector(".drawer-close").focus();
      else openBtn.focus();
    };
    openBtn.addEventListener("click", function () { setOpen(true); });
    document.querySelectorAll("[data-drawer-close]").forEach(function (el) {
      el.addEventListener("click", function () { setOpen(false); });
    });
    document.addEventListener("keydown", function (event) {
      if (event.key === "Escape" && document.body.classList.contains("drawer-open")) setOpen(false);
    });
  }

  // 從書頁按「上一頁」回來時，把翻開的書闔上
  window.addEventListener("pageshow", function () {
    document.querySelectorAll(".shelf-item.is-opening").forEach(function (el) {
      el.classList.remove("is-opening");
    });
  });
})();
