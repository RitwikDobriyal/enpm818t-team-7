# src/config/database.py
import psycopg_pool
import os
from dotenv import load_dotenv

load_dotenv()


class DatabaseConfig:
    _pool = None

    @classmethod
    def _conninfo(cls):
        return (
            f"host={os.getenv('DB_HOST', 'localhost')} "
            f"port={os.getenv('DB_PORT', '5432')} "
            f"dbname={os.getenv('DB_NAME')} "
            f"user={os.getenv('DB_USER')} "
            f"password={os.getenv('DB_PASSWORD')}"
        )

    @classmethod
    def initialize(cls):
        cls._pool = psycopg_pool.ConnectionPool(
            conninfo=cls._conninfo(),
            min_size=2,
            max_size=10,
            open=True
        )

    @classmethod
    def get_connection(cls):
        if cls._pool is None:
            cls.initialize()
        return cls._pool.connection()

    @classmethod
    def close_all(cls):
        if cls._pool is not None:
            cls._pool.close()
            cls._pool = None
