railsでajax post

coffee
$ ->
  $('.js-destroy').on "click", (event) ->
    if !window.confirm('登録します。よろしいですか？')
      event.preventDefault()
      return false
    id = $(this).data('id')
    local = $(this).data('local')
    Rails.ajax
      url: '/psth/' + id + '?local=' + local
      type: 'delete'
      dataType: 'json'
      async: true
      success: (response) ->
        location.reload()

controller
  # ajax
  def destroy
    model = Model.find_by id: params[:id]
    model.attr = false
    model.save!
    flash[:success] = "登録しました。"
    render json: {result: 'success'}.to_json
  end

view
= link_to '登録', '#', class: 'js-destroy', data: {id: model.id, 'local': params[:local] == '1' ? 1 : 0}, remote: true
--------------------------------------------------------------------------------
