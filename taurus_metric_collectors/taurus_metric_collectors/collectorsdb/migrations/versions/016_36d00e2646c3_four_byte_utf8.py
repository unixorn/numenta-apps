"""four-byte-utf8

Revision ID: 36d00e2646c3
Revises: 375d9de88cfd
Create Date: 2017-05-11 17:15:41.782171

"""

# revision identifiers, used by Alembic.
revision = '36d00e2646c3'
down_revision = '375d9de88cfd'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql


def upgrade():
    # Change real_name and retweeted_real_name columns to 4-byte UTF8
    # to support embedded emoji
    op.alter_column('twitter_tweets', 'real_name',
                    type_=mysql.VARCHAR(
                        length=100,
                        charset="utf8mb4",
                        collation="utf8mb4_unicode_ci"),
                    existing_nullable=True)

    op.alter_column('twitter_tweets', 'retweeted_real_name',
                    type_=mysql.VARCHAR(
                        length=100,
                        charset="utf8mb4",
                        collation="utf8mb4_unicode_ci"),
                    existing_nullable=True,
                    existing_server_default="")



def downgrade():
    raise NotImplementedError("Rollback is not supported.")
