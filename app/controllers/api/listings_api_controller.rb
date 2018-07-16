class Api::ListingsApiController < Api::ApiBaseController

  def index
    render json: {mesage: 'hello world'}
  end

  def create
    @current_user = Person.find_by_username(params[:listing][:username])
    @category_id = Category.find_by_url(params[:listing][:category]).id
    shape = ListingShape.find_by_name(params[:listing][:listing_shape])
    listing_uuid = UUIDUtils.create
    listing_info = listingInfo(params, @category_id, shape.id)
    result = ListingFormViewUtils.build_listing_params(shape, listing_uuid, listing_info, @current_community)
    @listing = Listing.new(result.data)
    params[:listing][:images].each do |image_url|
      listing_image = @listing.listing_images.new({author_id: @current_user.id})
      listing_image.save
      Delayed::Job.enqueue(DownloadListingImageJob.new(listing_image.id, image_url), priority: 1)
    end
    ActiveRecord::Base.transaction do
      @listing.author = @current_user
      @listing.upsert_field_values!(params.to_unsafe_hash[:custom_fields])
      @listing.reorder_listing_images(params, @current_user.id)
      @listing.save
    end
    render json: {message: @listing.id}
  end

  def listingInfo(params, category_id, listing_shape_id)
    ActionController::Parameters.new({
                                         listing: {
                                             title: params[:listing][:title],
                                             price: params[:listing][:price],
                                             shipping_price: params[:listing][:shipping_price],
                                             shipping_price_additional: params[:listing][:shipping_price_additional],
                                             delivery_methods: [
                                                 params[:listing][:delivery_methods]
                                             ],
                                             description: params[:listing][:description],
                                             category_id: category_id,
                                             listing_shape_id: listing_shape_id,
                                             affiliate_url: params[:listing][:affiliate_url],
                                             origin: params[:listing][:origin],
                                         }
                                     })
  end

end
