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

    # Solr検索
    def search(query, options)
      json = HTTPClient.new.get_content('http://localhost:8983/solr/gourmet/select', {
        q: query,
        wt: 'json'
      })
      data = JSON.parse(json)
      ids = data['response']['docs'].map { |d| d['id'] }
      find(ids)
    end

    private

    # SolrへPOSTするリクエスト
    def post_to_solr(content)
      HTTPClient.new.post_content('http://localhost:8983/solr/gourmet/update/json?commit=true',
                                  content.to_json,
                                  'Content-Type' => 'application/json')
    end
  end

end
