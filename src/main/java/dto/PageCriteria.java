package dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class PageCriteria {
    private int page; // 1-based
    private int size; // 페이지당 개수 (기본 18, 1~100 권장)

    public PageCriteria(Integer page, Integer size) {
        this.page = (page == null || page < 1) ? 1 : page;
        int s = (size == null) ? 12 : size; // 기본값: 18개 (6열 × 3줄)
        this.size = Math.max(1, Math.min(100, s));
    }

    public int offset() {
        return (page - 1) * size;
    }
}
