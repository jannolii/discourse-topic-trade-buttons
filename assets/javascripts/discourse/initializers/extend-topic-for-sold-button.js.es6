import Topic from 'discourse/models/topic';
import { withPluginApi } from 'discourse/lib/plugin-api';
import computed from 'ember-addons/ember-computed-decorators';

function initializeWithApi(api) {

  const currentUser = api.getCurrentUser();

  Topic.reopen({
    @computed('archived', 'closed')
    canTopicBeMarkedAsSold: function() {
      const enable_sold_button = this.category_enable_sold_button;
      return !this.isPrivatemessage
        && currentUser.id === this.user_id
        && this.siteSettings.topic_trade_buttons_enabled
        && enable_sold_button
        && !this.get('archived')
    },

    @computed('archived', 'closed')
    canTopicBeMarkedAsPurchased: function() {
      const enable_purchased_button = this.category_enable_purchased_button;
      return !this.isPrivatemessage
        && currentUser.id === this.user_id
        && this.siteSettings.topic_trade_buttons_enabled
        && enable_purchased_button
        && !this.get('archived')
    },

    @computed('archived', 'closed')
    canTopicBeMarkedAsExchanged: function() {
      const enable_exchanged_button = this.category_enable_exchanged_button;
      return !this.isPrivatemessage
        && currentUser.id === this.user_id
        && this.siteSettings.topic_trade_buttons_enabled
        && enable_exchanged_button
        && !this.get('archived')
    },

    @computed('archived', 'closed')
    canTopicBeMarkedAsCancelled: function() {
      const enable_cancelled_button = this.category_enable_cancelled_button;
      return !this.isPrivatemessage
        && currentUser.id === this.user_id
        && this.siteSettings.topic_trade_buttons_enabled
        && enable_cancelled_button
        && !this.get('archived')
    }

  });
}

export default {
  name: 'extend-topic-for-sold-button',
  initialize() {

    withPluginApi('0.1', initializeWithApi);

  }
}
