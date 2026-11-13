import DeleteIcon from "@mui/icons-material/Delete";
import EditIcon from "@mui/icons-material/Edit";
import Box from "@mui/material/Box";
import ButtonBase from "@mui/material/ButtonBase";
import IconButton from "@mui/material/IconButton";
import Typography from "@mui/material/Typography";
import { t } from "@lingui/core/macro";
import { useState } from "react";
import type { CommunityResource } from "@/api/types";
import { ConstrainedBody } from "@/components/ConstrainedBody";
import { useConfirm } from "@/components/ConfirmDialog";
import { EmptyPageContent } from "@/components/EmptyPageContent";
import { Img } from "@/components/Img";
import { ScaffoldFab } from "@/components/layout/AppScaffold";
import { useToast } from "@/components/Toast";
import { ErrorState, LoadingState } from "@/components/States";
import { useResources, useRemoveResource } from "@/queries/content";
import { useCommunityScope } from "@/scopes/CommunityScope";
import { ResourceDialog } from "./ResourceDialog";
import { colors } from "@/theme/tokens";

/** `/space/:displayId/resources`: link cards (60px picture + title); admins can add, edit and delete. */
export function ResourcesPage() {
  const { community, permissions } = useCommunityScope();
  const resources = useResources(community.id);
  const remove = useRemoveResource(community.id);
  const { confirm, dialog } = useConfirm();
  const toast = useToast();
  const [editing, setEditing] = useState<CommunityResource | "new" | null>(
    null,
  );

  return (
    <Box component="main">
      <ConstrainedBody>
        <Box>
          {resources.isPending ? (
            <LoadingState height={300} />
          ) : resources.isError ? (
            <ErrorState message={t`Something went wrong loading resources.`} />
          ) : resources.data.length === 0 ? (
            <Box sx={{ pt: "30px", display: "flex", justifyContent: "center" }}>
              <EmptyPageContent
                type="resources"
                showContainer={false}
                onButtonPress={
                  permissions.canEditCommunity
                    ? () => setEditing("new")
                    : undefined
                }
              />
            </Box>
          ) : (
            <>
              {resources.data.map((r) => (
                <Box
                  key={r.id}
                  sx={{
                    border: "1px solid",
                    borderColor: colors.outlineVariant,
                    borderRadius: "12px",
                    bgcolor: colors.surfaceContainerLowest,
                    display: "flex",
                    alignItems: "center",
                    pr: "8px",
                  }}
                >
                  <ButtonBase
                    component="a"
                    href={r.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    sx={{
                      flex: 1,
                      minWidth: 0,
                      p: "20px",
                      gap: "20px",
                      justifyContent: "flex-start",
                      textAlign: "left",
                      borderRadius: "10px",
                    }}
                  >
                    <Img src={r.image} width={60} height={60} radius="10px" />
                    <Typography sx={{ flex: 1, minWidth: 0 }}>
                      {r.title}
                    </Typography>
                  </ButtonBase>
                  {permissions.canEditCommunity && (
                    <>
                      <IconButton
                        aria-label={t`Edit ${r.title}`}
                        onClick={() => setEditing(r)}
                      >
                        <EditIcon />
                      </IconButton>
                      <IconButton
                        aria-label={t`Delete ${r.title}`}
                        onClick={async () => {
                          if (
                            await confirm({
                              mainText: t`Are you sure you want to delete this resource?`,
                            })
                          ) {
                            try {
                              await remove.mutateAsync(r.id);
                            } catch {
                              toast.error(t`Something went wrong. Please try again.`);
                            }
                          }
                        }}
                      >
                        <DeleteIcon />
                      </IconButton>
                    </>
                  )}
                </Box>
              ))}
            </>
          )}
        </Box>
      </ConstrainedBody>
      <Box sx={{ height: 100 }} />
      {permissions.canEditCommunity && (
        <ScaffoldFab text={t`Add a resource`} onClick={() => setEditing("new")} />
      )}
      {dialog}
      {editing && (
        <ResourceDialog
          resource={editing === "new" ? undefined : editing}
          onClose={() => setEditing(null)}
        />
      )}
    </Box>
  );
}
