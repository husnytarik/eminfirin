-- =========================================================
-- EMIN FIRIN — Supabase Şeması
-- QR Menü + Admin Panel için
-- =========================================================

-- ① Kategoriler
create table if not exists categories (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  slug        text not null unique,
  sort_order  int  not null default 0,
  created_at  timestamptz not null default now()
);

-- ② Menü ürünleri
create table if not exists menu_items (
  id           uuid primary key default gen_random_uuid(),
  category_id  uuid not null references categories(id) on delete cascade,
  name         text not null,
  description  text,
  price        numeric(8,2) not null,
  image_url    text,
  available    boolean not null default true,
  sort_order   int     not null default 0,
  created_at   timestamptz not null default now()
);

-- =========================================================
-- RLS (Row Level Security)
-- =========================================================

alter table categories  enable row level security;
alter table menu_items  enable row level security;

-- Herkes okuyabilir (QR menü için)
create policy "public_read_categories"
  on categories for select
  using (true);

create policy "public_read_menu_items"
  on menu_items for select
  using (available = true);

-- Sadece giriş yapmış kullanıcı yazabilir (admin panel için)
create policy "auth_all_categories"
  on categories for all
  to authenticated
  using (true)
  with check (true);

create policy "auth_all_menu_items"
  on menu_items for all
  to authenticated
  using (true)
  with check (true);

-- =========================================================
-- Storage: Ürün görselleri için bucket
-- =========================================================
-- Supabase Dashboard > Storage > New bucket: "menu-images" (public: true)
-- Veya SQL ile:

insert into storage.buckets (id, name, public)
values ('menu-images', 'menu-images', true)
on conflict (id) do nothing;

-- Herkes görselleri okuyabilir
create policy "public_read_images"
  on storage.objects for select
  using (bucket_id = 'menu-images');

-- Sadece giriş yapmış kullanıcı yükleyebilir / silebilir
create policy "auth_upload_images"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'menu-images');

create policy "auth_delete_images"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'menu-images');

-- =========================================================
-- Başlangıç verileri (isteğe bağlı)
-- =========================================================

insert into categories (name, slug, sort_order) values
  ('Ekmekler',        'ekmekler',        1),
  ('Poğaça & Börek',  'pogaca-borek',    2),
  ('Simit & Açma',    'simit-acma',      3),
  ('Tatlı Ürünler',   'tatli-urunler',   4),
  ('Sandviç & Ekmek', 'sandvic-ekmek',   5),
  ('İçecekler',       'icecekler',       6)
on conflict (slug) do nothing;
