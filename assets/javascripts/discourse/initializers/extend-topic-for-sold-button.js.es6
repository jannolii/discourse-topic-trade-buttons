import { withPluginApi } from "discourse/lib/plugin-api";
import Topic from "discourse/models/topic";
import computed from "discourse-common/utils/decorators";

function isEnabled(value) {
  if (value === true) {
    return true;
  }
  if (typeof value === "string") {
    const normalized = value.toLowerCase();
    return normalized === "true" || normalized === "t";
  }
  return false;
}

function initializeWithApi(api) {
  const currentUser = api.getCurrentUser();

  Topic.reopen({
    @computed("archived")
    canTopicBeMarkedAsSold: function () {
      return (
        !this.isPrivatemessage &&
        currentUser &&
        currentUser.id === this.user_id &&
        this.siteSettings.topic_trade_buttons_enabled &&
        isEnabled(this.category_enable_sold_button) &&
        !this.get("archived")
      );
    },

    @computed("archived")
    canTopicBeMarkedAsPurchased: function () {
      return (
        !this.isPrivatemessage &&
        currentUser &&
        currentUser.id === this.user_id &&
        this.siteSettings.topic_trade_buttons_enabled &&
        isEnabled(this.category_enable_purchased_button) &&
        !this.get("archived")
      );
    },

    @computed("archived")
    canTopicBeMarkedAsExchanged: function () {
      return (
        !this.isPrivatemessage &&
        currentUser &&
        currentUser.id === this.user_id &&
        this.siteSettings.topic_trade_buttons_enabled &&
        isEnabled(this.category_enable_exchanged_button) &&
        !this.get("archived")
      );
    },

    @computed("archived")
    canTopicBeMarkedAsCancelled: function () {
      return (
        !this.isPrivatemessage &&
        currentUser &&
        currentUser.id === this.user_id &&
        this.siteSettings.topic_trade_buttons_enabled &&
        isEnabled(this.category_enable_cancelled_button) &&
        !this.get("archived")
      );
    },
  });
}

export default {
  name: "extend-topic-for-sold-button",
  initialize() {
    withPluginApi("0.1", initializeWithApi);
  },
};
