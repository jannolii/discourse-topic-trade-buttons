# name: discourse-topic-trade-buttons
# about: Adds one or all buttons (Sold, Purchased, Exchanged) to designated categories
# meta_topic_id: 71308
# version: 0.0.3
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

    class TradeError < StandardError
    end
  end

  class DiscourseTopicTradeButtons::Trade
    TRANSACTIONS = %w[sold purchased exchanged cancelled].freeze

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
        raise Discourse::InvalidParameters.new(:topic_id) unless TRANSACTIONS.include?(transaction)

        topic_id = topic_id.to_i
        raise Discourse::InvalidParameters.new(:topic_id) if topic_id <= 0

        DistributedMutex.synchronize("#{PLUGIN_NAME}-#{topic_id}") do
          topic = Topic.find_by(id: topic_id)

          raise Discourse::NotFound if topic.nil? || topic.trashed?
          raise Discourse::InvalidAccess if topic.private_message?
          raise Discourse::InvalidAccess unless topic.user_id == user.id || user.staff?

          unless topic.category&.custom_fields["enable_#{transaction}_button"].to_s == "true"
            raise Discourse::InvalidAccess
          end

          if topic.archived
            raise DiscourseTopicTradeButtons::TradeError.new(I18n.t("topic.topic_must_be_open_to_edit"))
          end

          i18n_transaction =
            I18n
              .t("topic_trading.#{transaction}", locale: (SiteSetting.default_locale || :en))
              .mb_chars
              .upcase

          topic.title = "[#{i18n_transaction}] #{topic.title}"
          topic.custom_fields["#{transaction}_at"] = Time.zone.now.iso8601
          topic.archived = true
          topic.save!

          topic.add_moderator_post(
            user,
            I18n.t(
              "topic_trading.#{transaction}_log",
              username: user.username,
              locale: (SiteSetting.default_locale || :en),
            ),
            post_type: Post.types[:small_action],
            action_code: "topic_trade_#{transaction}",
            bump: false,
          )

          topic
        end
      end
    end
  end

  require_dependency "application_serializer"

  class TopicTradeButtonsSerializer < ApplicationSerializer
    attributes :id, :title, :fancy_title, :archived
  end

  require_dependency "application_controller"

  class DiscourseTopicTradeButtons::TradeController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    before_action :ensure_logged_in

    def sold
      perform_trade("sold")
    end

    def purchased
      perform_trade("purchased")
    end

    def exchanged
      perform_trade("exchanged")
    end

    def cancelled
      perform_trade("cancelled")
    end

    private

    def perform_trade(transaction)
      topic_id = params.require(:topic_id)
      topic = DiscourseTopicTradeButtons::Trade.trade(transaction, topic_id, current_user)
      render json: topic, serializer: TopicTradeButtonsSerializer
    rescue DiscourseTopicTradeButtons::TradeError => e
      render_json_error e.message
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
