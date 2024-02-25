class WhatsappContext
  attr_accessor :wa_id,
                :phone,
                :msg_type,
                :msg_body,
                :interactive_reply,
                :user,
                :conversation

  def initialize(webhook_data)
    @wa_id = webhook_data[:phone_number_id]
    @phone = webhook_data[:from]
    @msg_type = webhook_data[:msg_type]
    @msg_body = webhook_data[:msg_body]
    @interactive_reply = webhook_data[:interactive_reply]
    @image_id = webhook_data[:image_id]

    @user = User.find_or_initialize_by(phone_number: @phone)
    @conversation = Conversation.find_or_initialize_by(user: @user)

    @whatsapp = WhatsappMethods.new(@wa_id, @phone)
  end

  def reply_type
    if global_keyword
      :global
    elsif @interactive_reply
      :interactive
    elsif @msg_type == 'text'
      :text
    elsif @msg_type == 'image'
      :image
    end
  end

  def try_again_prompt
    failed_attempts = @conversation.data['failed_attempts'] || 0

    if failed_attempts >= 3
      update_data({ failed_attempts: 0 })
      ask_for_category
      return
    end

    rand = rand(1..3)
    case rand
    when 1
      @whatsapp.text('Sorry, I did not understand that. Please try again.')
    when 2
      @whatsapp.text('I did not get that. Please try again.')
    when 3
      @whatsapp.text('Can you please try again?')
    end
    update_data({ failed_attempts: failed_attempts + 1 })
  end

  def update_data(data)
    @conversation.update(data: @conversation.data.merge(data))
  end

  def handle_global_keyword
    case global_keyword
    when :restart
      @whatsapp.text('Restart Triggered')
    when :debug
      @whatsapp.text('Debugging...')
    end
  end

  def handle_interactive_reply
    reply = @interactive_reply[:id]

    @whatsapp.text("You have selected *#{reply}*.")
  end

  def handle_text_reply
    if user.new_record?
      user.save
      step_ask_for_name
    elsif @conversation.pending_name?
      step_received_name(@msg_body)
    else
      @whatsapp.text("You have entered: #{@msg_body}")
    end
  end

  def handle_image_reply
    if @image_id
      @whatsapp.text('Thank you for the image.')
    else
      @whatsapp.text('Sorry, I did not receive the image. Please try again.')
    end
  end

  private

  def step_ask_for_name
    @whatsapp.text('Welcome! Before we get started, can I please have your name?')
    @conversation.update(current_step: :pending_name)
  end

  def step_received_name(name)
    @user.update(full_name: name)
    @whatsapp.text("Thank you, #{@user&.full_name}.")
  end

  def global_keyword
    restart_keywords = [
      'restart',
      'reset',
      'start over',
      'start again',
      'restart conversation',
      'reset conversation',
      'start over conversation',
      'start again conversation',
      'main menu',
      'menu'
    ]

    if @msg_body == 'DEBUG'
      :debug
    elsif restart_keywords.include?(@msg_body&.strip&.downcase)
      :restart
    else
      false
    end
  end
end
