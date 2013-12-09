module Spree
  module Api
    class IntegratorController < Spree::Api::BaseController
      prepend_view_path File.expand_path('../../../../app/views', File.dirname(__FILE__))

      before_filter :authorize_read!

      helper_method :collection_attributes,
                    :product_attributes

      respond_to :json

      before_filter :set_default_filter,
        only: [:show_orders,
               :show_users,
               :show_products,
               :show_return_authorizations]

      def index
        # keep before poll-anything compatibility - https://trello.com/c/emcq710r
        if params[:message] != 'hub:poll'
          set_default_filter
          index_v5
          render :index_v5 and return
        end

        @collections = [
          OpenStruct.new({ name: 'orders',                 token: 'number',  frequency: '5.minutes' }),
          OpenStruct.new({ name: 'users',                  token: 'email',   frequency: '5.minutes' }),
          OpenStruct.new({ name: 'products',               token: 'sku',     frequency: '1.hour' }),
          OpenStruct.new({ name: 'return_authorizations',  token: 'number',  frequency: '1.hour' })
        ]
      end

      def index_v5
        @orders = filter_resource(Spree::Order.complete)
        @stock_transfers = filter_resource(Spree::StockTransfer)
      end

      def show_orders
        @orders = filter_resource(Spree::Order.complete)
      end

      def show_users
        @users = filter_resource(Spree.user_class)
      end

      def show_products
        @products = filter_resource(Spree::Product)
      end

      def show_return_authorizations
        @return_authorizations = filter_resource(Spree::ReturnAuthorization)
      end

      private
      def set_default_filter
        @since    = params[:since] || 1.day.ago
        @page     = params[:page]  || 1
        @per_page = params[:per_page]
      end

      def filter_resource(relation)
        relation.ransack(updated_at_gteq: @since).result
        .page(@page)
        .per(@per_page)
        .order('updated_at ASC')
      end

      def collection_attributes
        [:name, :token, :frequency]
      end

      def product_attributes
        [:id, :sku, :name, :description, :price, :available_on, :permalink, :meta_description, :meta_keywords, :shipping_category_id, :taxon_ids, :updated_at]
      end

      def authorize_read!
        unless current_api_user && current_api_user.has_spree_role?("admin")
          raise CanCan::AccessDenied
        end
      end
    end
  end
end
