# frozen_string_literal: true

require 'spec_helper'

describe 'Drbd::Common_suboptions' do
  describe 'valid types' do
    context 'with valid types' do
      [
        {},
        { 'options' => [] },
        { 'net' => %w[somevalue another] },
      ].each do |value|
        describe value.inspect do
          it { is_expected.to allow_value(value) }
        end
      end
    end
  end

  describe 'invalid types' do
    context 'with garbage inputs' do
      [
        true,
        nil,
        { 'foo' => 'bar' },
        'a string',
      ].each do |value|
        describe value.inspect do
          it { is_expected.not_to allow_value(value) }
        end
      end
    end
  end
end
