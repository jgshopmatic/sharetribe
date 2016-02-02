module ListingIndexService::Search

  class SearchEngineAdapter

    def search(community_id:, search:)
      raise InterfaceMethodNotImplementedError.new
    end

    protected

    def success_result(count, listings, includes)
      Result::Success.new(
        {count: count, listings: listings.map { |l| ListingIndexService::Search::Commons.listing_hash(l, includes) }})
    end

    def fetch_from_db(community_id:, search:, included_models:, includes:)
      where_opts = HashUtils.compact(
        {
          community_id: community_id,
          author_id: search[:author_id],
          deleted: 0
        })

      query = Listing
        .where(where_opts)
        .includes(included_models)
        .order("listings.sort_date DESC")
        .paginate(per_page: search[:per_page], page: search[:page])

      listings =
        if search[:include_closed]
          query
        else
          query.currently_open
        end

      success_result(listings.total_entries, listings, includes)
    end

    def needs_db_query?(search)
      search[:author_id].present? || search[:include_closed] == true
    end

    def needs_search?(search)
      [
        :keywords,
        :listing_shape_id,
        :categories, :fields,
        :price_cents
      ].any? { |field| search[field].present? }
    end
  end
end
