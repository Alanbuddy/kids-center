class MaterialsController < ApplicationController

  def create
    image = Image.new
    image.image = params[:wangEditorH5File] || params[:wangEditorPasteFile]
    image.store_image!
    filepath = image.image.file.file
    render text: "/uploads/images/" + filepath.split('/')[-1] and return
  end
end