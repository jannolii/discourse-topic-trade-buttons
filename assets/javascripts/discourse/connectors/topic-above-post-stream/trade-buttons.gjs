import Component from "@glimmer/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import { ajax } from "discourse/lib/ajax";
import { i18n } from "discourse-i18n";

export default class TradeButtons extends Component {
  @service dialog;

  performTrade(transaction) {
    const topic = this.args.outletArgs.model;

    return this.dialog.yesNoConfirm({
      message: i18n(`topic_trading.mark_as_${transaction}_confirm`),
      didConfirm: () => {
        ajax(`/topic/${transaction}`, {
          type: "PUT",
          data: { topic_id: topic.id },
        })
          .then((result) => {
            topic.set("title", result.topic_trade_buttons.title);
            topic.set("fancy_title", result.topic_trade_buttons.fancy_title);
            topic.set("archived", result.topic_trade_buttons.archived);
          })
          .catch(() => {
            this.dialog.alert({
              message: i18n(
                `topic_trading.error_while_marked_as_${transaction}`
              ),
            });
          });
      },
    });
  }

  @action
  clickSold() {
    this.performTrade("sold");
  }

  @action
  clickPurchased() {
    this.performTrade("purchased");
  }

  @action
  clickExchanged() {
    this.performTrade("exchanged");
  }

  @action
  clickCancelled() {
    this.performTrade("cancelled");
  }

  <template>
    {{#if @outletArgs.model.canTopicBeMarkedAsSold}}
      <DButton
        @class="btn btn-primary"
        @action={{this.clickSold}}
        @label="topic_trading.sold"
      />
    {{/if}}
    {{#if @outletArgs.model.canTopicBeMarkedAsPurchased}}
      <DButton
        @class="btn btn-primary"
        @action={{this.clickPurchased}}
        @label="topic_trading.purchased"
      />
    {{/if}}
    {{#if @outletArgs.model.canTopicBeMarkedAsExchanged}}
      <DButton
        @class="btn btn-primary"
        @action={{this.clickExchanged}}
        @label="topic_trading.exchanged"
      />
    {{/if}}
    {{#if @outletArgs.model.canTopicBeMarkedAsCancelled}}
      <DButton
        @class="btn"
        @action={{this.clickCancelled}}
        @label="topic_trading.cancelled"
      />
    {{/if}}
  </template>
}
