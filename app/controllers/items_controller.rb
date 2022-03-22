class ItemsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update]
  before_action :set_item, only: [:show, :edit, :update]
  before_action :redirect_to_show, only: [:edit, :update]

  def index
    @items = Item.all
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to root_path
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @item.update(item_params)
      redirect_to root_path
    else
      render :edit
    end
  end

  def search
    # params[:q]がnilではない且つ、params[:q][:name]がnilではないとき（商品名の欄が入力されているとき）
    # if params[:q] && params[:q][:name]と同じような意味合い
    # &.:nilの場合は「nil」を返す
    # dig:ネストしたハッシュからキーを指定して値を取り出す
    if params[:q]&.dig(:name)
      # squishメソッド:冒頭と末尾のスペースを削除、連続したスペースを1つに減らす
      squished_keywords = params[:q][:name].squish
      # 半角スペースを区切り文字として配列を生成し、paramsに入れる
      # _any:いずれかに一致する検索（ransackのオプション）
      params[:q][:name_cont_any] = squished_keywords.split(" ")
    end
    # ransack:検索オブジェクトを生成
    # params[:q]:ransackを使用したフォームから送られてくるパラメーターを受け取る
    @q = Item.ransack(params[:q])
    # result:検索結果を取得
    @items = @q.result
  end

  private
  def item_params
    params.require(:item).permit(:name, :image, :category_id, :price).merge(user_id: current_user.id)
  end

  def set_item
    @item = Item.find(params[:id])
  end

  def redirect_to_show
    return redirect_to root_path if current_user.id != @item.user.id
  end
end
