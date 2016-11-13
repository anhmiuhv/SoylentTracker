#include <pebble.h>
#include <string.h>

static GFont s_time_font;
static Window *s_main_window;
static TextLayer *s_label_layer;
static int count;
static BitmapLayer *s_background_layer[20];
static GBitmap *s_background_bitmap;

static void update_bottles(int new_value) {
  Layer *window_layer = window_get_root_layer(s_main_window);
  //layer_remove_child_layers(window_layer);
  for (int i = count - 1; i >= 0; i--) {
    bitmap_layer_destroy(s_background_layer[i]);
  }
  for (int i = 0; i < new_value; i++) {
    s_background_layer[i] = bitmap_layer_create(GRect(20+20*(i%6), 30+30*(i/6), 30, 30));
    bitmap_layer_set_bitmap(s_background_layer[i], s_background_bitmap);
    layer_add_child(window_layer, bitmap_layer_get_layer(s_background_layer[i]));
  }
  count = new_value;
}

static void select_click_handler2(ClickRecognizerRef recognizer, void *context) {
  update_bottles(9);
}

static void select_click_handler(ClickRecognizerRef recognizer, void *context) {
  // A single click has just occured
  if (count < 20) count++;
  Layer *window_layer = window_get_root_layer(s_main_window);
  // Create BitmapLayer to display the GBitmap
  s_background_layer[count-1] = bitmap_layer_create(GRect(20+20*((count-1)%6), 30+30*((count-1)/6), 30, 30));

  // Set the bitmap onto the layer and add to the window
  bitmap_layer_set_bitmap(s_background_layer[count-1], s_background_bitmap);
  layer_add_child(window_layer, bitmap_layer_get_layer(s_background_layer[count-1]));

  // Declare the dictionary's iterator
  DictionaryIterator *out_iter;

  // Prepare the outbox buffer for this message
  AppMessageResult result = app_message_outbox_begin(&out_iter);
  if(result == APP_MSG_OK) {
    // Construct the message
    dict_write_int(out_iter, 0, &count, sizeof(int), true);
    // Send this message
    result = app_message_outbox_send();
    // Check the result
    if(result != APP_MSG_OK) {
      APP_LOG(APP_LOG_LEVEL_ERROR, "Error sending the outbox: %d", (int)result);
    }
  } else {
    // The outbox cannot be used right now
    APP_LOG(APP_LOG_LEVEL_ERROR, "Error preparing the outbox: %d", (int)result);
  }
}

static void click_config_provider(void *context) {
  // Subcribe to button click events here
  ButtonId id = BUTTON_ID_UP;  // The Select button

  window_single_click_subscribe(id, select_click_handler);
  window_single_click_subscribe(BUTTON_ID_DOWN, select_click_handler2);
}

// Messages callback

static void inbox_received_callback(DictionaryIterator *iter, void *context) {
  // A new message has been successfully received

  // Does this message contain a temperature value?
  Tuple *value_tuple = dict_find(iter, 0);
  if(value_tuple) {
    // This value was stored as JS Number, which is stored here as int32_t
    update_bottles(value_tuple->value->int32);
  }
}

static void inbox_dropped_callback(AppMessageResult reason, void *context) {
  // A message was received, but had to be dropped
  APP_LOG(APP_LOG_LEVEL_ERROR, "Message dropped. Reason: %d", (int)reason);
}

static void outbox_sent_callback(DictionaryIterator *iter, void *context) {
  // The message just sent has been successfully delivered

}

static void outbox_failed_callback(DictionaryIterator *iter,
                                      AppMessageResult reason, void *context) {
  // The message just sent failed to be delivered
  APP_LOG(APP_LOG_LEVEL_ERROR, "Message send failed. Reason: %d", (int)reason);
}

static void main_window_load(Window *window) {
  // Get information about the Window
  Layer *window_layer = window_get_root_layer(window);
  GRect bounds = layer_get_bounds(window_layer);

  // Create the TextLayer with specific bounds
  s_label_layer = text_layer_create(
    GRect(0, 10, bounds.size.w, 50));

  // Create GBitmap
  s_background_bitmap = gbitmap_create_with_resource(RESOURCE_ID_IMAGE_BACKGROUND);

  // Improve the layout
  text_layer_set_background_color(s_label_layer, GColorClear);
  text_layer_set_text_color(s_label_layer, GColorBlack);
  text_layer_set_text(s_label_layer, "Bottles:");
  // Create GFont
  s_time_font = fonts_load_custom_font(resource_get_handle(RESOURCE_ID_FONT_PERFECT_DOS_20));
  // Apply to TextLayer
  text_layer_set_font(s_label_layer, s_time_font);
  text_layer_set_text_alignment(s_label_layer, GTextAlignmentCenter);

  // Add it as a child layer to the Window's root layer
  layer_add_child(window_layer, text_layer_get_layer(s_label_layer));

  // Use this provider to add button click subscriptions
  window_set_click_config_provider(window, click_config_provider);
}

static void main_window_unload(Window *window) {
  // Destroy TextLayer
  text_layer_destroy(s_label_layer);
  gbitmap_destroy(s_background_bitmap);
  for (int i = 0; i < count; i++) {
    bitmap_layer_destroy(s_background_layer[i]);
  }
}

static void init() {
  // Create main Window element and assign to pointer
  s_main_window = window_create();

  // Set handlers to manage the elements inside the Window
  window_set_window_handlers(s_main_window, (WindowHandlers) {
    .load = main_window_load,
    .unload = main_window_unload
  });

  // Show the Window on the watch, with animated=true
  window_stack_push(s_main_window, true);

  count = 0;

  app_message_open(inbox_size, outbox_size);
  // Register to be notified about inbox received events
  app_message_register_inbox_received(inbox_received_callback);
  // Register to be notified about inbox dropped events
  app_message_register_inbox_dropped(inbox_dropped_callback);
  // Register to be notified about outbox sent events
  app_message_register_outbox_sent(outbox_sent_callback);
  // Register to be notified about outbox failed events
  app_message_register_outbox_failed(outbox_failed_callback);
}

static void deinit() {
  // Destroy Window
  window_destroy(s_main_window);
}

int main(void) {
  init();
  app_event_loop();
  deinit();
}