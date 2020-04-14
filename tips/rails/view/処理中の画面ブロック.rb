ajax処理中の画面ブロック

$('.screen-blocker').hide()
$('.screen-blocker').show()

<style lang='scss' scoped>
  .screen-blocker {
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
    z-index: 9999999;
    background-color: rgba(0, 0, 0, 0.2)
  }
</style>
