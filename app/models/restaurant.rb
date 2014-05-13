require 'net/http'
require 'uri'

class Restaurant < ActiveRecord::Base
  belongs_to :area
  belongs_to :pref


  class << self

    # レストランデータをSolrへPOSTしindexさせる
    def index_documents
      find_in_batches(batch_size: 100) do |restaurants|
        hash = restaurants.map do |restaurant|
          {
            id: restaurant.id,
            name: restaurant.name,
            property: restaurant.property,
            alphabet: restaurant.alphabet,
            description: restaurant.description
          }
        end

        post_to_solr(hash)
      end
    end

    private

    # SolrへPOSTするリクエスト
    def post_to_solr(content)
      http_client = HTTPClient.new
      endpoint_uri = 'http://localhost:8983/solr/gourmet/update/json?commit=true'
      http_client.post_content(endpoint_uri, content.to_json, 'Content-Type' => 'application/json')
    end
  end

end
