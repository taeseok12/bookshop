package dto;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class PageResult<T> {
    private List<T> content;
    private int page;
    private int size;
    private int total;
    private int totalPages;
    private boolean hasPrev;
    private boolean hasNext;

    public PageResult(List<T> content, int page, int size, int total) {
        this.content = content;
        this.page = page;
        this.size = size;
        this.total = total;
        this.totalPages = (int) Math.ceil(total / (double) size);
        this.hasPrev = page > 1;
        this.hasNext = page < totalPages;
    }
}
