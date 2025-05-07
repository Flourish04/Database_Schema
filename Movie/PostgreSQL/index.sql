CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- dim_user
CREATE INDEX        idx_dim_user_name_trgm            ON dim_user USING GIN (name gin_trgm_ops);   -- tìm theo họ tên
-- Nếu sẽ truy vấn theo ngày sinh (birthday reminders…)
CREATE INDEX        idx_dim_user_dob                  ON dim_user(date_of_birth);

-- dim_movie
CREATE INDEX        idx_dim_movie_release_date        ON dim_movie(release_date);
CREATE INDEX        idx_dim_movie_total_rating        ON dim_movie(total_rating);
CREATE INDEX        idx_dim_movie_rating_count        ON dim_movie(rating_total_count);
-- Tìm gần đúng theo tên phim (pg_trgm)
CREATE INDEX        idx_dim_movie_name_trgm           ON dim_movie USING GIN (name gin_trgm_ops);
-- Nếu thường lọc theo quốc gia + ngôn ngữ
CREATE INDEX        idx_dim_movie_country_lang        ON dim_movie(country, language);

-- dim_genres
-- Bảng nhỏ, PK đã đủ – KHÔNG cần thêm index

-- dim_person
CREATE INDEX        idx_dim_person_name_trgm          ON dim_person USING GIN (name gin_trgm_ops);
CREATE INDEX        idx_dim_person_gender             ON dim_person(gender);


-- dim_movie_genres
CREATE INDEX idx_movie_genres_movie_id  ON dim_movie_genres(movie_id);
CREATE INDEX idx_movie_genres_genre_id  ON dim_movie_genres(genre_id);

-- dim_credits
CREATE INDEX idx_credits_movie_id       ON dim_credits(movie_id);
CREATE INDEX idx_credits_person_id_role ON dim_credits(person_id, role);
-- CREATE INDEX idx_credits_job_trgm ON dim_credits USING GIN (job gin_trgm_ops);


-- Lấy tất cả rating của 1 phim
CREATE INDEX idx_fact_rating_movie            ON fact_movie_rating(movie_id);
-- Lấy lịch sử rating của 1 user (NEW → OLD)
-- CREATE INDEX idx_fact_rating_user_date_desc   ON fact_movie_rating(user_id, date DESC);
-- -- Phân tích rating theo thang điểm
-- CREATE INDEX idx_fact_rating_rating           ON fact_movie_rating(rating);
-- Truy vấn time-series theo timestamp
CREATE INDEX idx_fact_rating_timestamp        ON fact_movie_rating(timestamp);

CREATE INDEX idx_search_log_user_date ON dim_search_log(user_id, date DESC);
