# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    if agent_signed_in?
      redirect_to temsilci_path
    else
      redirect_to musteri_path
    end
  end
end
