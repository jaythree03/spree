class ProductsController < Spree::BaseController
  helper :taxons
  resource_controller
  actions :show, :index

  index do
    before do
      @product_cols = 3
    end
  end

  def change_image
    @product = Product.available.find_by_param(params[:id])
    img = Image.find(params[:image_id])
    render :partial => 'image', :locals => {:image => img}
  end

  private

    def collection
      if params[:taxon]
        @taxon = Taxon.find(params[:taxon])

        @collection ||= Product.available.find(
          :all, 
          :conditions => ["products.id in (select product_id from products_taxons where taxon_id in (" +  @taxon.descendents.inject( @taxon.id.to_s) { |clause, t| clause += ', ' + t.id.to_s} + "))" ], 
          :page => {:start => 1, :size => 10, :current => params[:p]}, 
          :include => :images)
      else
        @collection ||= Product.available.find(:all, :page => {:start => 1, :size => 10, :current => params[:p]}, :include => :images)
      end
    end
end
