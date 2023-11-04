import { popupAjaxError } from 'discourse/lib/ajax-error';
import Topic from 'discourse/models/topic';
import { ajax } from 'discourse/lib/ajax';
import { getOwner } from "@ember/application";
import I18n from "discourse-i18n";

export default {
  actions: {
    clickSoldButton(topic) {
      const dialog = getOwner(this).lookup("service:dialog");
      return dialog.yesNoConfirm({
        message: I18n.t('topic_trading.mark_as_sold_confirm'),
        didConfirm: () => {
          ajax("/topic/sold", {
            type: "PUT",
            data: {
              topic_id: topic.id
            }
          }).then((result) => {
            topic.set('custom_fields.sold_at', result.topic.sold_at);
            topic.set('title', result.topic.title);
            topic.set('fancy_title', result.topic.fancy_title);
            topic.set('archived', result.topic.archived);
          }).catch(() => {
            dialog.alert({
              message: I18n.t('topic_trading.error_while_marked_as_sold')
            });
          })
        },
      });
    },

    clickPurchasedButton(topic) {
      const dialog = getOwner(this).lookup("service:dialog");
      return dialog.yesNoConfirm({
        message: I18n.t('topic_trading.mark_as_purchased_confirm'),
        didConfirm: () => {
          ajax("/topic/purchased", {
            type: "PUT",
            data: {
              topic_id: topic.id
            }
          }).then((result) => {
            topic.set('custom_fields.purchased_at', result.topic.purchased_at);
            topic.set('title', result.topic.title);
            topic.set('fancy_title', result.topic.fancy_title);
            topic.set('archived', result.topic.archived);
          }).catch(() => {
            dialog.alert({
              message: I18n.t('topic_trading.error_while_marked_as_purchased')
            });
          })
        },
      });
    },

    clickExchangedButton(topic) {
      const dialog = getOwner(this).lookup("service:dialog");
      return dialog.yesNoConfirm({
        message: I18n.t('topic_trading.mark_as_exchanged_confirm'),
        didConfirm: () => {
          ajax("/topic/exchanged", {
            type: "PUT",
            data: {
              topic_id: topic.id
            }
          }).then((result) => {
            topic.set('custom_fields.exchanged_at', result.topic.exchanged_at);
            topic.set('title', result.topic.title);
            topic.set('fancy_title', result.topic.fancy_title);
            topic.set('archived', result.topic.archived);
          }).catch(() => {
            dialog.alert({
              message: I18n.t('topic_trading.error_while_marked_as_exchanged')
            });
          })
        },
      });
    },

    clickCancelledButton(topic) {
      const dialog = getOwner(this).lookup("service:dialog");
      return dialog.yesNoConfirm({
        message: I18n.t('topic_trading.mark_as_cancelled_confirm'),
        didConfirm: () => {
          ajax("/topic/cancelled", {
            type: "PUT",
            data: {
              topic_id: topic.id
            }
          }).then((result) => {
            topic.set('custom_fields.cancelled_at', result.topic.cancelled_at);
            topic.set('title', result.topic.title);
            topic.set('fancy_title', result.topic.fancy_title);
            topic.set('archived', result.topic.archived);
          }).catch(() => {
            dialog.alert({
              message: I18n.t('topic_trading.error_while_marked_as_cancelled')
            });
          })
        },
      });
    }
  }
};
