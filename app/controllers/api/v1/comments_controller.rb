class Api::V1::CommentsController < ApplicationController
  load_and_authorize_resource only: [:update, :destroy]

  swagger_controller :comments, "Comment management"

  swagger_api :create do
    summary 'Creates a comment'
    notes 'Comment on MicroBlog/Comment/Share'
    param :form, :"comment[message]", :string, :required, 'Comment content'
    param :form, :"comment[item_id]", :integer, :required, 'MicroBlog/Comment/Share ID'
    param_list :form, :"comment[item_type]", :string, :required, 'Item name to comment', Comment::ListBy::ITEMS
    response :created
    response :unauthorized
    response :bad_request
  end
  def create
  end

  swagger_api :update do
    summary 'Updates a comment'
    notes 'Update comment message'
    param :path, :id, :string, :required, 'Comment ID'
    param :form, :"comment[message]", :string, :required, 'Comment content'
    response :ok
    response :unauthorized
    response :bad_request
  end
  def update
    if @comment.update(message: params[:comment][:message])
      render_success_json
    else
      render_error_state(@comment.errors.full_messages.join(', '), :bad_request)
    end
  end

  swagger_api :destroy do
    summary 'Delete action'
    notes 'Deletes a comment'
    param :path, :id, :integer, :required, 'Comment ID'
    response :ok
    response :unauthorized
    response :bad_request
  end
  def destroy
    @comment.destroy_record
    render_success_json
  end

  private
  def comment_params
    params.require(:comment).permit(:message, :item_id, :item_type)
  end
end
