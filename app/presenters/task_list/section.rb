module TaskList
  class Section < SectionRenderer
    def render
      tag.li do
        safe_join(
          [header, body],
        )
      end
    end
  end
end
