import { getOwner } from "@ember/application";
import { ajax } from "discourse/lib/ajax";
import I18n from "discourse-i18n";

export default {
  actions: {
    clickSoldButton(topic) {
      const dialog = getOwner(this).lookup("service:dialog");
      return dialog.yesNoConfirm({
        message: I18n.t("topic_trading.mark_as_sold_confirm"),
        didConfirm: () => {
          ajax("/topic/sold", {
            type: "PUT",
            data: {
              topic_id: topic.id,
            },
          })
            .then((result) => {
              topic.set("title", result.topic_trade_buttons.title);
              topic.set("fancy_title", result.topic_trade_buttons.fancy_title);
              topic.set("archived", result.topic_trade_buttons.archived);
            })
            .catch(() => {
              dialog.alert({
                message: I18n.t("topic_trading.error_while_marked_as_sold"),
              });
            });
        },
      });
    },

    clickPurchasedButton(topic) {
      const dialog = getOwner(this).lookup("service:dialog");
      return dialog.yesNoConfirm({
        message: I18n.t("topic_trading.mark_as_purchased_confirm"),
        didConfirm: () => {
          ajax("/topic/purchased", {
            type: "PUT",
            data: {
              topic_id: topic.id,
            },
          })
            .then((result) => {
              topic.set("title", result.topic_trade_buttons.title);
              topic.set("fancy_title", result.topic_trade_buttons.fancy_title);
              topic.set("archived", result.topic_trade_buttons.archived);
            })
            .catch(() => {
              dialog.alert({
                message: I18n.t(
                  "topic_trading.error_while_marked_as_purchased"
                ),
              });
            });
        },
      });
    },

    clickExchangedButton(topic) {
      const dialog = getOwner(this).lookup("service:dialog");
      return dialog.yesNoConfirm({
        message: I18n.t("topic_trading.mark_as_exchanged_confirm"),
        didConfirm: () => {
          ajax("/topic/exchanged", {
            type: "PUT",
            data: {
              topic_id: topic.id,
            },
          })
            .then((result) => {
              topic.set("title", result.topic_trade_buttons.title);
              topic.set("fancy_title", result.topic_trade_buttons.fancy_title);
              topic.set("archived", result.topic_trade_buttons.archived);
            })
            .catch(() => {
              dialog.alert({
                message: I18n.t(
                  "topic_trading.error_while_marked_as_exchanged"
                ),
              });
            });
        },
      });
    },

    clickCancelledButton(topic) {
      const dialog = getOwner(this).lookup("service:dialog");
      return dialog.yesNoConfirm({
        message: I18n.t("topic_trading.mark_as_cancelled_confirm"),
        didConfirm: () => {
          ajax("/topic/cancelled", {
            type: "PUT",
            data: {
              topic_id: topic.id,
            },
          })
            .then((result) => {
              topic.set("title", result.topic_trade_buttons.title);
              topic.set("fancy_title", result.topic_trade_buttons.fancy_title);
              topic.set("archived", result.topic_trade_buttons.archived);
            })
            .catch(() => {
              dialog.alert({
                message: I18n.t(
                  "topic_trading.error_while_marked_as_cancelled"
                ),
              });
            });
        },
      });
    },
  },
};
