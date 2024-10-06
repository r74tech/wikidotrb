require 'spec_helper'
require 'wikidotrb/util/parser/odate'
require 'nokogiri'

RSpec.describe Wikidotrb::Util::Parser::ODateParser do
  describe '.parse' do
    context '正しいodate要素が渡された場合' do
      let(:html) do
        <<-HTML
          <span class="odate time_1633036800">2021-10-01 00:00:00</span>
        HTML
      end
      let(:elem) { Nokogiri::HTML.fragment(html).at_css('span') }
      let(:expected_time) { Time.at(1633036800) }

      it 'Timeオブジェクトを返すこと' do
        time = described_class.parse(elem)
        expect(time).to eq(expected_time)
      end
    end

    context 'unix timeのクラスが含まれているものの、Invalidなodate要素が渡された場合' do
      let(:html) do
        <<-HTML
          <span class="odate time_8640000000001">Invalid Date</span>
        HTML
      end
      let(:elem) { Nokogiri::HTML.fragment(html).at_css('span') }
      
      it 'UnexpectedExceptionを発生させること' do
        expect { described_class.parse(elem) }.to raise_error(Wikidotrb::Common::Exceptions::UnexpectedException, 'Invalid unix time')
      end
    end

    context 'unix timeのクラスが含まれていないodate要素が渡された場合' do
      let(:html) do
        <<-HTML
          <span class="odate">Invalid time</span>
        HTML
      end
      let(:elem) { Nokogiri::HTML.fragment(html).at_css('span') }

      it 'ArgumentErrorを発生させること' do
        expect { described_class.parse(elem) }.to raise_error(ArgumentError, 'odate element does not contain a valid unix time')
      end
    end

    context 'Nokogiri::XML::Elementではない文字列が渡された場合' do
      let(:html_string) { '<span class="odate time_1633036800">2021-10-01 00:00:00</span>' }
      let(:expected_time) { Time.at(1633036800) }

      it 'Timeオブジェクトを返すこと' do
        time = described_class.parse(html_string)
        expect(time).to eq(expected_time)
      end
    end

    context '要素がnilの場合' do
      it 'ArgumentErrorを発生させること' do
        expect { described_class.parse(nil) }.to raise_error(ArgumentError, 'odate element does not contain a valid unix time')
      end
    end

    context '複数のクラスを持つodate要素が渡された場合' do
      let(:html) do
        <<-HTML
          <span class="odate time_1633036800 format_%25e%20%25b%20%25Y%2C%20%25H%3A%25M%20%28%25O%20%E5%89%8D%29">2021-10-01 00:00:00</span>
        HTML
      end
      let(:elem) { Nokogiri::HTML.fragment(html).at_css('span') }
      let(:expected_time) { Time.at(1633036800) }

      it 'Timeオブジェクトを返すこと' do
        time = described_class.parse(elem)
        expect(time).to eq(expected_time)
      end
    end

    context '別のタグで囲まれているodate要素が渡された場合' do
      let(:html) do
        <<-HTML
          <div>
            <span class="odate time_1633036800">2021-10-01 00:00:00</span>
          </div>
        HTML
      end
      let(:elem) { Nokogiri::HTML.fragment(html).at_css('span') }
      let(:expected_time) { Time.at(1633036800) }

      it 'Timeオブジェクトを返すこと' do
        time = described_class.parse(elem)
        expect(time).to eq(expected_time)
      end
    end
  end
end
