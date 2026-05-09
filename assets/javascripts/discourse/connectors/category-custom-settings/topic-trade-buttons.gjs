import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";

export default class TopicTradeButtonsCategorySettings extends Component {
  static shouldRender(args, context) {
    return context.siteSettings.topic_trade_buttons_enabled;
  }

  @service siteSettings;

  @action
  onToggle(field, event) {
    this.args.outletArgs.category.set(
      `custom_fields.${field}`,
      event.target.checked
    );
  }

  <template>
    {{#if @outletArgs.form}}
      <@outletArgs.form.Section
        @title={{i18n "topic_trading.category_settings_heading"}}
        class="category-custom-settings-outlet topic-trade-buttons-category-settings"
      >
        <@outletArgs.form.Object @name="custom_fields" as |object|>
          <object.Field
            @name="enable_sold_button"
            @title={{i18n "topic_trading.enable_sold_button"}}
            @format="max"
            @type="checkbox"
            as |field|
          >
            <field.Control />
          </object.Field>

          <object.Field
            @name="enable_purchased_button"
            @title={{i18n "topic_trading.enable_purchased_button"}}
            @format="max"
            @type="checkbox"
            as |field|
          >
            <field.Control />
          </object.Field>

          <object.Field
            @name="enable_exchanged_button"
            @title={{i18n "topic_trading.enable_exchanged_button"}}
            @format="max"
            @type="checkbox"
            as |field|
          >
            <field.Control />
          </object.Field>

          <object.Field
            @name="enable_cancelled_button"
            @title={{i18n "topic_trading.enable_cancelled_button"}}
            @format="max"
            @type="checkbox"
            as |field|
          >
            <field.Control />
          </object.Field>
        </@outletArgs.form.Object>
      </@outletArgs.form.Section>
    {{else}}
      <div
        class="category-custom-settings-outlet topic-trade-buttons-category-settings"
      >
        <h3>{{i18n "topic_trading.category_settings_heading"}}</h3>
        <section class="field">
          <label class="checkbox-label">
            <input
              id="enable-sold-button"
              type="checkbox"
              checked={{@outletArgs.category.custom_fields.enable_sold_button}}
              {{on "change" (fn this.onToggle "enable_sold_button")}}
            />
            {{i18n "topic_trading.enable_sold_button"}}
          </label>
          <label class="checkbox-label">
            <input
              id="enable-purchased-button"
              type="checkbox"
              checked={{@outletArgs.category.custom_fields.enable_purchased_button}}
              {{on "change" (fn this.onToggle "enable_purchased_button")}}
            />
            {{i18n "topic_trading.enable_purchased_button"}}
          </label>
          <label class="checkbox-label">
            <input
              id="enable-exchanged-button"
              type="checkbox"
              checked={{@outletArgs.category.custom_fields.enable_exchanged_button}}
              {{on "change" (fn this.onToggle "enable_exchanged_button")}}
            />
            {{i18n "topic_trading.enable_exchanged_button"}}
          </label>
          <label class="checkbox-label">
            <input
              id="enable-cancelled-button"
              type="checkbox"
              checked={{@outletArgs.category.custom_fields.enable_cancelled_button}}
              {{on "change" (fn this.onToggle "enable_cancelled_button")}}
            />
            {{i18n "topic_trading.enable_cancelled_button"}}
          </label>
        </section>
      </div>
    {{/if}}
  </template>
}
