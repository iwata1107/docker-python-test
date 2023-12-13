# 使用するPythonのバージョンを指定
ARG PYTHON_VERSION=3.11.4
FROM python:${PYTHON_VERSION}-slim as base

# Pythonがpycファイルを生成しないように設定
ENV PYTHONDONTWRITEBYTECODE=1

# Pythonの出力をバッファリングしないように設定
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# 非特権ユーザーを作成
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

# 依存関係のインストール
# Pipのキャッシュを活用してビルドを高速化
RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
    python -m pip install -r requirements.txt

# 非特権ユーザーに切り替え
USER appuser

# ソースコードをコピー
COPY . .

# アプリケーションを実行（ここでスクリプトを指定）
CMD ["python", "main.py"]
