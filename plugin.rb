# name: discourse-topic-trade-buttons
# about: Adds one or all buttons (Sold, Purchased, Exchanged) to designated categories
# meta_topic_id: 71308
# version: 0.0.1
# authors: Janno Liivak
# frozen_string_literal: true

enabled_site_setting :topic_trade_buttons_enabled

PLUGIN_NAME ||= "discourse_topic_trade_buttons".freeze

after_initialize do
  add_to_serializer(:topic_view, :category_enable_sold_button, include_condition: -> { object.topic.category }) do
    object.topic.category.custom_fields["enable_sold_button"]
  end

  add_to_serializer(:topic_view, :category_enable_purchased_button, include_condition: -> { object.topic.category }) do
    object.topic.category.custom_fields["enable_purchased_button"]
  end

  add_to_serializer(:topic_view, :category_enable_exchanged_button, include_condition: -> { object.topic.category }) do
    object.topic.category.custom_fields["enable_exchanged_button"]
  end

  add_to_serializer(:topic_view, :category_enable_cancelled_button, include_condition: -> { object.topic.category }) do
    object.topic.category.custom_fields["enable_cancelled_button"]
  end

  add_to_serializer(:topic_view, :custom_fields, include_condition: -> { object.topic.category && scope.user&.admin? }) do
    object.topic.custom_fields
  end

  module ::DiscourseTopicTradeButtons
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscourseTopicTradeButtons
    end
  end

  class DiscourseTopicTradeButtons::Trade
    class << self
      def sold(topic_id, user)
        trade("sold", topic_id, user)
      end

      def purchased(topic_id, user)
        trade("purchased", topic_id, user)
      end

      def exchanged(topic_id, user)
        trade("exchanged", topic_id, user)
      end

      def cancelled(topic_id, user)
        trade("cancelled", topic_id, user)
      end

      def trade(transaction, topic_id, user)
        DistributedMutex.synchronize("#{PLUGIN_NAME}-#{topic_id}") do
          user_id = user.id
          topic = Topic.find_by_id(topic_id)

          # topic must not be deleted
          raise StandardError.new I18n.t("topic.topic_is_deleted") if topic.nil? || topic.trashed?

          # topic must not be archived
          raise StandardError.new I18n.t("topic.topic_must_be_open_to_edit") if topic.try(:archived)

          topic.archived = true
          i18n_transaction =
            I18n
              .t("topic_trading.#{transaction}", locale: (SiteSetting.default_locale || :en))
              .mb_chars
              .upcase
          topic.title = "[#{i18n_transaction}] #{topic.title}"
          topic.custom_fields["#{transaction}_at"] = Time.zone.now.iso8601
          topic.save!

          return topic
        end
      end
    end
  end

  require_dependency "application_controller"

  class DiscourseTopicTradeButtons::TradeController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    before_action :ensure_logged_in

    def sold
      topic_id = params.require(:topic_id)

      begin
        topic = DiscourseTopicTradeButtons::Trade.sold(topic_id, current_user)
        render json: { topic: topic }
      rescue StandardError => e
        render_json_error e.message
      end
    end

    def purchased
      topic_id = params.require(:topic_id)

      begin
        topic = DiscourseTopicTradeButtons::Trade.purchased(topic_id, current_user)
        render json: { topic: topic }
      rescue StandardError => e
        render_json_error e.message
      end
    end

    def exchanged
      topic_id = params.require(:topic_id)

      begin
        topic = DiscourseTopicTradeButtons::Trade.exchanged(topic_id, current_user)
        render json: { topic: topic }
      rescue StandardError => e
        render_json_error e.message
      end
    end

    def cancelled
      topic_id = params.require(:topic_id)

      begin
        topic = DiscourseTopicTradeButtons::Trade.cancelled(topic_id, current_user)
        render json: { topic: topic }
      rescue StandardError => e
        render_json_error e.message
      end
    end
  end

  DiscourseTopicTradeButtons::Engine.routes.draw do
    put "/sold" => "trade#sold"
    put "/purchased" => "trade#purchased"
    put "/exchanged" => "trade#exchanged"
    put "/cancelled" => "trade#cancelled"
  end

  Discourse::Application.routes.append { mount ::DiscourseTopicTradeButtons::Engine, at: "/topic" }
end
